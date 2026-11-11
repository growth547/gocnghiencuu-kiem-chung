# Góc Nghiên Cứu Scale Library: metadata of 121 measurement scales used in Vietnamese theses

*Thư viện thang đo Góc Nghiên Cứu: siêu dữ liệu của 121 thang đo dùng trong khoá luận, luận văn ở Việt Nam (phần tiếng Việt ở dưới).*

## What this is

A machine-readable index of the 121 measurement scales documented at https://gocnghiencuu.com/thang-do/ (English pages for 119 of them at https://gocnghiencuu.com/en/scales/). Each scale page shows the original English items, a Vietnamese translation, reverse-scored items, reliability evidence and the full APA references. This dataset holds the **metadata** of those pages: what each scale measures, how many items and dimensions it has, the response format, who developed it, the DOIs of its sources, published reliability values with their sources, and Vietnamese studies that used it.

Fields covered: technology and information systems, consumer behaviour, service quality, marketing and branding, human resources and organisational behaviour, psychology and mental health.

## What this is not: no item wording

The dataset deliberately contains **no item text**, neither the English originals nor the Vietnamese translations.

- The wording of a scale belongs to its original authors (and, for some instruments, to a publisher that sells licences). Republishing the items as a bulk downloadable dataset under an open licence would grant rights we do not hold.
- The Vietnamese translations are derivative works of those items, so the same limit applies.
- The scale pages show the items for the research use the authors intended, with the citation next to them. Each row here links to that page (`url_vi`, `url_en`), and `license_note_vi` records what we found about the terms of use of each scale. Always cite the original authors (`references_apa`) when you use a scale.

## Files

| File | Rows | Content |
|---|---|---|
| `scales.csv` | 121 | One row per scale: id, abbreviation, full name, field, number of constructs / items / reverse-scored items, response format, construct codes and names (EN, VI), original sources, reference DOIs, APA references, licence note, page URLs |
| `constructs.csv` | 309 | One row per construct (dimension): scale id, code, English and Vietnamese name, number of items, number of reverse-scored items, source |
| `reliability.csv` | 182 | Published reliability values (Cronbach's alpha, composite reliability…) with sample description, source and source URL |
| `vietnam-studies.csv` | 77 | Vietnamese studies that used the scale: authors, year, title, journal, URL |
| `scales.json` | 121 | Same as `scales.csv` plus `verified_from` (the URLs each scale was checked against) |

CSV files are UTF-8 with BOM (opens correctly in Excel); multi-valued cells are separated by ` | `.

## How it was built

Every scale page is written from the original article or the scale author's own page and checked against at least one open full text or Crossref record (listed in `verified_from`). Editorial policy: https://gocnghiencuu.com/phuong-phap-bien-soan/. The files are generated from the scale pages; a new version is published when scales are added or corrected.

## Licence

Metadata compiled by the Góc Nghiên Cứu editorial team: **CC BY 4.0**. You may reuse and redistribute with attribution. Bibliographic facts (titles, DOIs, reliability values) come from the cited publications; the scales themselves remain under their authors' terms (see `license_note_vi`).

## Citation

Ban biên tập Góc Nghiên Cứu (2026). *Góc Nghiên Cứu Scale Library: metadata of 121 measurement scales used in Vietnamese theses* (Version 1.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.XXXXXXX

Corrections: gocnghiencuu1203@gmail.com or https://gocnghiencuu.com/about/.

---

## Tiếng Việt

Bộ dữ liệu là mục lục máy đọc được của 121 thang đo trên https://gocnghiencuu.com/thang-do/: thang đo đo gì, bao nhiêu khái niệm và biến quan sát, thang trả lời, tác giả gốc, DOI nguồn, hệ số tin cậy đã công bố kèm nguồn, các nghiên cứu ở Việt Nam đã dùng.

**Không có nguyên văn câu hỏi** (cả bản gốc tiếng Anh lẫn bản dịch tiếng Việt), vì câu chữ của thang đo thuộc tác giả gốc, một số thang phải mua quyền; bản dịch là tác phẩm phái sinh nên cũng vậy. Câu hỏi xem trên trang của từng thang đo (cột `url_vi`), kèm trích dẫn. Khi dùng thang đo, trích dẫn tác giả gốc (cột `references_apa`).

Giấy phép phần siêu dữ liệu: CC BY 4.0 (dùng lại, chia sẻ, ghi nguồn). Báo lỗi: gocnghiencuu1203@gmail.com.
