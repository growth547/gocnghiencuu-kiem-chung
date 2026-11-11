# Reference values for https://gocnghiencuu.com/en/verification/ (compare with results/kiem-chung.json).
# Public data sets (written to data/ so readers can download exactly what was run):
#   psych::bfi                          - 2,800 people, 25 Big Five items (Revelle, SAPA project)
#   lavaan::HolzingerSwineford1939      - 301 pupils, 9 ability tests (Holzinger & Swineford, 1939)
#   seminr::mobi                        - 250 mobile-phone customers, ECSI model (Tenenhaus et al., 2005)
# References computed here:
#   Cronbach's alpha, item-total columns  - psych::alpha
#   KMO, Bartlett                         - psych::KMO, psych::cortest.bartlett
#   EFA, SPSS defaults (PAF, varimax / promax) - EFAtools::EFA(type = "SPSS")
#   Regression, t test, ANOVA, Levene     - stats::lm, t.test, oneway.test (base R)
#   PLS-SEM                               - seminr::estimate_pls (path weighting, the SmartPLS default)
#   Sample size                           - noncentral F power in base R (the G*Power method); inverse square root formula
# Run from the repository root:  Rscript reference/kiem_chung_reference.R
# (install.packages(c("psych", "lavaan", "seminr", "EFAtools", "GPArotation", "jsonlite")))
suppressPackageStartupMessages({ library(psych); library(lavaan); library(seminr); library(EFAtools); library(jsonlite) })
dir.create("data", showWarnings = FALSE); dir.create("reference/output", showWarnings = FALSE, recursive = TRUE)
r10 <- function(x) round(x, 10)

# ---- data, written as plain CSV (empty cell = missing) ----
bfi <- psych::bfi
bfi$id <- seq_len(nrow(bfi))
bfi <- bfi[, c("id", setdiff(names(bfi), "id"))]
hs <- lavaan::HolzingerSwineford1939
mobi <- seminr::mobi
write.csv(bfi, "data/bfi.csv", row.names = FALSE, na = "")
write.csv(hs, "data/holzinger-swineford-1939.csv", row.names = FALSE, na = "")
write.csv(mobi, "data/mobi.csv", row.names = FALSE, na = "")

# ---- Cronbach's alpha: bfi's five scales (reverse-keyed items recoded 7 - x), HS's three ability blocks ----
rev_bfi <- c("A1", "C4", "C5", "E1", "E2", "O2", "O5")
bfr <- bfi
for (v in rev_bfi) bfr[[v]] <- 7 - bfr[[v]]
alpha_case <- function(d, items, label) {
  x <- na.omit(d[, items])
  a <- psych::alpha(x, check.keys = FALSE, warnings = FALSE)
  list(label = label, items = items, n = nrow(x), alpha = r10(a$total$raw_alpha), std_alpha = r10(a$total$std.alpha),
       citc = r10(unname(a$item.stats$r.drop)), alpha_if_deleted = r10(unname(a$alpha.drop$raw_alpha)))
}
cronbach <- c(
  lapply(c("A", "C", "E", "N", "O"), function(s) alpha_case(bfr, paste0(s, 1:5), paste0("bfi ", s))),
  list(alpha_case(hs, paste0("x", 1:3), "HS visual"), alpha_case(hs, paste0("x", 4:6), "HS textual"), alpha_case(hs, paste0("x", 7:9), "HS speed"))
)

# ---- EFA with SPSS defaults ----
efa_case <- function(x, k, label) {
  x <- na.omit(x); R <- cor(x)
  vm <- EFA(R, n_factors = k, N = nrow(x), method = "PAF", rotation = "varimax", type = "SPSS")
  pm <- EFA(R, n_factors = k, N = nrow(x), method = "PAF", rotation = "promax", type = "SPSS")
  b <- psych::cortest.bartlett(R, n = nrow(x))
  list(label = label, items = colnames(x), n = nrow(x), k = k,
       kmo = r10(psych::KMO(R)$MSA), msa = r10(unname(psych::KMO(R)$MSAi)),
       bartlett_chi = r10(b$chisq), bartlett_df = b$df,
       eigen = r10(eigen(R, symmetric = TRUE)$values),
       paf_unrotated = r10(unclass(vm$unrot_loadings)), h2 = r10(unname(vm$h2)),
       varimax = r10(unclass(vm$rot_loadings)),
       promax_pattern = r10(unclass(pm$rot_loadings)), promax_phi = r10(unclass(pm$Phi)))
}
efa <- list(efa_case(bfr[, paste0(rep(c("A", "C", "E", "N", "O"), each = 5), 1:5)], 5, "bfi 25 items"),
            efa_case(hs[, paste0("x", 1:9)], 3, "HS x1-x9"))

# ---- regression: HS, x9 (speeded discrimination) on x1, x4, x7 and age in years ----
X <- c("x1", "x4", "x7", "ageyr")
fit <- lm(x9 ~ x1 + x4 + x7 + ageyr, data = hs); sm <- summary(fit); res <- residuals(fit)
vif <- sapply(X, function(v) 1 / (1 - summary(lm(reformulate(setdiff(X, v), v), data = hs))$r.squared))
regression <- list(y = "x9", x = X, n = nrow(hs),
  b0 = r10(unname(coef(fit)[1])), b = r10(unname(coef(fit)[-1])), se = r10(unname(sm$coefficients[-1, 2])),
  t = r10(unname(sm$coefficients[-1, 3])), p = r10(unname(sm$coefficients[-1, 4])),
  beta = r10(unname(coef(fit)[-1] * sapply(hs[X], sd) / sd(hs$x9))), vif = r10(unname(vif)),
  r2 = r10(sm$r.squared), adj_r2 = r10(sm$adj.r.squared), F = r10(unname(sm$fstatistic[1])),
  dw = r10(sum(diff(res)^2) / sum(res^2)))

# ---- independent t test: HS x1 by sex; one-way ANOVA: bfi agreeableness score by education ----
g1 <- hs$x1[hs$sex == 1]; g2 <- hs$x1[hs$sex == 2]
ts <- t.test(g1, g2, var.equal = TRUE); tw <- t.test(g1, g2, var.equal = FALSE)
ttest <- list(y = "x1", group = "sex", n = c(length(g1), length(g2)),
  student = list(t = r10(unname(ts$statistic)), df = unname(ts$parameter), p = r10(ts$p.value)),
  welch = list(t = r10(unname(tw$statistic)), df = r10(unname(tw$parameter)), p = r10(tw$p.value)))
d <- na.omit(data.frame(A = rowMeans(bfr[, paste0("A", 1:5)]), edu = bfr$education))
d$edu <- factor(d$edu)
ow <- oneway.test(A ~ edu, data = d, var.equal = TRUE); wl <- oneway.test(A ~ edu, data = d, var.equal = FALSE)
d$dev <- abs(d$A - ave(d$A, d$edu)); lv <- anova(lm(dev ~ edu, data = d))
anova_ref <- list(y = "mean of A1 (reversed) to A5", group = "education", n = nrow(d), groups = as.integer(table(d$edu)),
  F = r10(unname(ow$statistic)), df1 = unname(ow$parameter[1]), df2 = unname(ow$parameter[2]), p = r10(ow$p.value),
  welch_F = r10(unname(wl$statistic)), welch_df2 = r10(unname(wl$parameter[2])), welch_p = r10(wl$p.value),
  levene_F = r10(lv$`F value`[1]), levene_p = r10(lv$`Pr(>F)`[1]))

# ---- PLS-SEM: the ECSI model (Tenenhaus et al., 2005) on mobi, without perceived quality (PERQ) ----
mm <- constructs(
  composite("Image", multi_items("IMAG", 1:5)), composite("Expectation", multi_items("CUEX", 1:3)),
  composite("Value", multi_items("PERV", 1:2)), composite("Satisfaction", multi_items("CUSA", 1:3)),
  composite("Complaints", single_item("CUSCO")), composite("Loyalty", multi_items("CUSL", 1:3)))
sm_paths <- list(c("Image", "Expectation"), c("Image", "Satisfaction"), c("Image", "Loyalty"), c("Expectation", "Value"),
  c("Expectation", "Satisfaction"), c("Value", "Satisfaction"), c("Satisfaction", "Complaints"), c("Satisfaction", "Loyalty"),
  c("Complaints", "Loyalty"))
st <- do.call(relationships, lapply(sm_paths, function(p) paths(from = p[1], to = p[2])))
pls <- estimate_pls(data = mobi, measurement_model = mm, structural_model = st)
ps <- summary(pls)
mat <- function(m) { m <- unclass(m); list(rows = rownames(m), cols = colnames(m), v = r10(matrix(as.numeric(m), nrow(m)))) }
plsref <- list(constructs = list(c("Image", paste0("IMAG", 1:5)), c("Expectation", paste0("CUEX", 1:3)), c("Value", paste0("PERV", 1:2)),
    c("Satisfaction", paste0("CUSA", 1:3)), c("Complaints", "CUSCO"), c("Loyalty", paste0("CUSL", 1:3))),
  paths_list = sm_paths, n = nrow(mobi), loadings = mat(ps$loadings), weights = mat(ps$weights), paths = mat(ps$paths),
  reliability = mat(ps$reliability), htmt = mat(ps$validity$htmt), iterations = ps$iterations)

# ---- sample size: multiple regression F test (G*Power's method) and the inverse square root method ----
reg_n <- function(m, f2, alpha, power) {
  n <- m + 2
  repeat { df2 <- n - m - 1
    if (pf(qf(1 - alpha, m, df2), m, df2, ncp = f2 * n, lower.tail = FALSE) >= power) return(n)
    n <- n + 1 }
}
grid <- expand.grid(m = c(2, 3, 5, 8, 10), f2 = c(0.02, 0.15, 0.35), alpha = 0.05, power = 0.8)
grid$n <- mapply(reg_n, grid$m, grid$f2, grid$alpha, grid$power)
isr <- expand.grid(pmin = c(0.1, 0.15, 0.2, 0.25, 0.3, 0.4, 0.5), alpha = c(0.01, 0.05, 0.1), power = 0.8)
isr$n <- ceiling(((qnorm(1 - isr$alpha) + qnorm(isr$power)) / isr$pmin)^2)

out <- list(generated = format(Sys.Date()),
  versions = list(R = R.version.string, psych = as.character(packageVersion("psych")), lavaan = as.character(packageVersion("lavaan")),
    seminr = as.character(packageVersion("seminr")), EFAtools = as.character(packageVersion("EFAtools"))),
  cronbach = cronbach, efa = efa, regression = regression, ttest = ttest, anova = anova_ref, pls = plsref,
  sample_size = list(regression = grid, isr = isr))
writeLines(toJSON(out, auto_unbox = TRUE, digits = NA, matrix = "rowmajor"), "reference/output/kiem-chung-reference.json")
cat("wrote reference/output/kiem-chung-reference.json and data/*.csv\n")
