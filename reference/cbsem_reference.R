# Reference values for the CB-SEM tool at https://gocnghiencuu.com/cong-cu/cb-sem/ (compare with results/kiem-chung.json).
# lavaan (Rosseel, 2012) with its defaults: ML, marker indicator, expected information, likelihood = "normal"
# (χ² = N·F); one case with likelihood = "wishart" (S with N − 1, χ² = (N − 1)·F, as AMOS reports).
# Data: the public files in data/ (Holzinger-Swineford 1939, mobi, bfi), listwise deletion.
# Run from the repository root:  Rscript reference/cbsem_reference.R
# (install.packages(c("lavaan", "semTools", "jsonlite")))
suppressPackageStartupMessages({ library(lavaan); library(semTools); library(jsonlite) })
hs <- read.csv("data/holzinger-swineford-1939.csv")
mobi <- read.csv("data/mobi.csv")
bfi <- read.csv("data/bfi.csv")

HS <- "visual =~ x1 + x2 + x3\ntextual =~ x4 + x5 + x6\nspeed =~ x7 + x8 + x9"
cases <- list(
  list(id = "hs-cfa", data = "hs", model = HS, fun = "cfa", likelihood = "normal"),
  list(id = "hs-cfa-wishart", data = "hs", model = HS, fun = "cfa", likelihood = "wishart"),
  list(id = "hs-second-order", data = "hs", fun = "cfa", likelihood = "normal",
       model = paste0(HS, "\ng =~ visual + textual + speed")),
  list(id = "hs-cfa-modified", data = "hs", fun = "cfa", likelihood = "normal",
       model = paste0(HS, "\nvisual =~ x9\nx2 ~~ x3")),
  list(id = "mobi-sem", data = "mobi", fun = "sem", likelihood = "normal",
       model = paste(
         "IMAG =~ IMAG1 + IMAG2 + IMAG3 + IMAG4 + IMAG5",
         "EXPE =~ CUEX1 + CUEX2 + CUEX3",
         "VAL =~ PERV1 + PERV2",
         "SAT =~ CUSA1 + CUSA2 + CUSA3",
         "LOY =~ CUSL1 + CUSL2 + CUSL3",
         "COMP =~ CUSCO",
         "VAL ~ EXPE",
         "SAT ~ IMAG + EXPE + VAL",
         "COMP ~ SAT",
         "LOY ~ SAT + IMAG + COMP", sep = "\n")),
  list(id = "bfi-cfa", data = "bfi", fun = "cfa", likelihood = "normal",
       model = paste(
         "A =~ A1 + A2 + A3 + A4 + A5", "C =~ C1 + C2 + C3 + C4 + C5", "E =~ E1 + E2 + E3 + E4 + E5",
         "N =~ N1 + N2 + N3 + N4 + N5", "O =~ O1 + O2 + O3 + O4 + O5", sep = "\n"))
)
datasets <- list(hs = hs, mobi = mobi, bfi = bfi)
# lavaan's default optimizer settings (check-cbsem.mjs also shows the tool reaches an equal or lower ML discrepancy).
CTRL <- list()

# Every chain X -> M ... -> Y of regression paths, as the tool enumerates them; effect = product of the paths.
chains <- function(pt) {
  reg <- pt[pt$op == "~", ]
  out <- list()
  walk <- function(path) {
    u <- path[length(path)]
    for (k in which(reg$rhs == u)) {
      v <- reg$lhs[k]
      if (v %in% path) next
      np <- c(path, v)
      if (length(np) >= 3) out[[length(out) + 1]] <<- np
      walk(np)
    }
  }
  for (s in unique(c(reg$rhs, reg$lhs))) walk(s)
  out
}

res <- lapply(cases, function(cs) {
  d <- datasets[[cs$data]]
  fun <- if (cs$fun == "cfa") cfa else sem
  f0 <- fun(cs$model, data = d, likelihood = cs$likelihood, missing = "listwise", control = CTRL)
  # Indirect effects through := (delta method, as lavaan reports them).
  ch <- chains(parTable(f0))
  model <- cs$model
  if (length(ch)) {
    pt <- parTable(f0)
    reg <- pt[pt$op == "~", ]
    lab <- setNames(paste0("b", seq_len(nrow(reg))), paste(reg$lhs, reg$rhs))
    lines <- strsplit(model, "\n")[[1]]
    lines <- unlist(lapply(lines, function(l) {
      if (!grepl("[^=]~[^~]", paste0(" ", l)) || grepl("=~|~~", l)) return(l)
      lhs <- trimws(sub("~.*", "", l)); rhs <- trimws(strsplit(sub(".*~", "", l), "\\+")[[1]])
      paste0(lhs, " ~ ", paste0(lab[paste(lhs, rhs)], "*", rhs, collapse = " + "))
    }))
    defs <- vapply(seq_along(ch), function(i) {
      nd <- ch[[i]]
      paste0("ind", i, " := ", paste(lab[paste(nd[-1], nd[-length(nd)])], collapse = "*"))
    }, "")
    model <- paste(c(lines, defs), collapse = "\n")
  }
  f <- fun(model, data = d, likelihood = cs$likelihood, missing = "listwise", control = CTRL)
  pe <- parameterEstimates(f)
  ss <- standardizedSolution(f)
  pe <- pe[pe$op %in% c("=~", "~", "~~", ":="), ]
  ss <- ss[ss$op %in% c("=~", "~", "~~", ":="), ]
  pe$std <- ss$est.std; pe$std.se <- ss$se
  ind <- pe[pe$op == ":=", ]
  pe <- pe[pe$op != ":=", c("lhs", "op", "rhs", "est", "se", "z", "pvalue", "std", "std.se")]
  fm <- fitMeasures(f0, c("chisq", "df", "pvalue", "baseline.chisq", "baseline.df", "cfi", "tli", "nfi", "ifi",
                          "rmsea", "rmsea.ci.lower", "rmsea.ci.upper", "rmsea.pvalue", "srmr", "gfi_lisrel", "agfi",
                          "logl", "aic", "bic", "npar", "ntotal"))
  mi <- modindices(f0, sort. = TRUE)
  mi <- mi[mi$op %in% c("=~", "~~") & !(mi$lhs %in% c()) , c("lhs", "op", "rhs", "mi", "epc")]
  mi <- head(mi, 15)
  lv <- lavNames(f0, "lv")
  stdl <- lavInspect(f0, "std")
  ht <- tryCatch(semTools::htmt(cs$model, data = d, missing = "listwise", htmt2 = FALSE), error = function(e) NULL)
  list(case = cs, ref = list(
    est = pe, fit = as.list(fm), mi = mi,
    rsquare = as.list(lavInspect(f0, "rsquare")),
    lvcor = lavInspect(f0, "cor.lv"),
    htmt = if (is.null(ht)) NULL else unclass(ht),
    indirect = if (nrow(ind)) lapply(seq_len(nrow(ind)), function(i) list(nodes = ch[[i]], est = ind$est[i], se = ind$se[i],
                                                                          std = ind$std[i], std.se = ind$std.se[i])) else list()
  ))
})
out <- list(versions = list(lavaan = as.character(packageVersion("lavaan")), semTools = as.character(packageVersion("semTools")),
                            R = paste(R.version$major, R.version$minor, sep = ".")),
            cases = res)
writeLines(toJSON(out, digits = 12, auto_unbox = TRUE, na = "null"), "reference/output/cbsem-reference.json")
cat("wrote reference/output/cbsem-reference.json\n")
