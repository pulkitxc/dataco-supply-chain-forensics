# DataCo Supply Chain Analytics

### End-to-End Analytics & Data Forensics Investigation

> I spent a month investigating a supply chain dataset.
> Turns out the dataset was fake.

---

## The short version

I took the [DataCo Supply Chain dataset](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis) — **180,519 rows, 53 columns** — and built a full end-to-end analytics system on it:

- Business Requirement Document
- 61-field data dictionary
- Data profiling + cleaning notebooks
- Star schema design with justification
- PostgreSQL warehouse
- 20-test validation suite
- 24 business questions across 8 domains
- 8 structured SQL investigations

Then the investigation turned into something else.

Every dimension showed **suspiciously uniform margins (~10–11%)**.
Categories were **randomly assigned** (golf balls classified as "Electronics").
Discount rates were **artificially equalized**.
Shipping data had **impossible zero-variance patterns**.

So I stopped interpreting. And I started investigating.

**Result:** the dataset is a research artifact, not real business data. It cannot support real business insights.

But the investigation can.

---

## Why this repo is different

Most portfolio projects are dashboards.

This is a **full analytical system** plus a **forensics audit** that questions whether the data deserves interpretation at all.

The deliverable isn't a chart.
It's a **34-page report** that ends with: *"Here's what the data can and cannot support."*

---

## The 9 forensics findings

| ID  | Finding                                              | Status       |
|-----|------------------------------------------------------|--------------|
| F1  | Dataset is a research artifact                       | ✅ Confirmed |
| F2  | October 2017 onward is synthetic                     | ✅ Confirmed |
| F3  | Market labels unstable across years                  | ✅ Confirmed |
| F4  | Margins uniformly ~10–11% across all dimensions      | ✅ Confirmed |
| F5  | Categories are randomly assigned                     | ✅ Confirmed |
| F6  | `order_profit_per_order` may be order-level          | ⚠️ Open      |
| F7  | $1,500 price anchor in extreme lines                 | ⚠️ Open      |
| F8  | Discount distribution is artificially equalized      | ✅ Confirmed |
| F9  | Shipping data is synthetic                           | ✅ Confirmed |

Full analysis in [`07_sql_workbook/dataco_sherlock_complete.sql`](./07_sql_workbook/dataco_sherlock_complete.sql).

---

## Repository structure

```
dataco-supply-chain-forensics/
│
├── README.md                      ← you are here
├── final_report.pdf               ← 34-page deliverable
│
├── 01_business_requirements/
│   └── DataCo_BRD.pdf
│
├── 02_source_discovery/
│   └── DataCo_Source_System_Discovery.pdf
│
├── 03_data_dictionary/
│   └── DataCo_Data_Dictionary.pdf
│
├── 04_profiling/
│   └── profiling.ipynb
│
├── 05_cleaning/
│   └── cleaning.ipynb
│
├── 06_data_modeling/
│   ├── 00_mental_model.md
│   └── 01_business_model.md
│
├── 07_sql_workbook/
│   └── dataco_sherlock_complete.sql
│       Complete SQL workbook containing:
│         • Warehouse construction (Phases 7–8)
│         • 20-test validation suite
│         • Investigation scripts 01–08
│         • Investigation findings 01–08
│         • Forensics findings F1–F9
│
└── 08_business_question_map/
    └── business_question_map.md
```

---

## Inside the SQL workbook

A single SQL file that documents the full investigation in one place.

**① Warehouse construction**
- Schema setup
- Dimension creation and population
- Fact table creation and population

**② Warehouse validation**
- 20 integrity tests across 5 principles
- All passed

**③ Investigations 01–08**
- Query for each investigation
- Findings for each investigation
- Forensics review for each investigation

**④ Forensics findings**
- Consolidated F1–F9
- Each with Claim / Evidence / Interpretation / Limitation

---

## Tech stack

| Layer             | Tool                                         |
|-------------------|----------------------------------------------|
| Warehouse         | PostgreSQL (star schema)                     |
| Data wrangling    | Python — pandas, numpy, SQLAlchemy           |
| SQL               | 20-test validation suite + 8 investigations   |
| Notebooks         | Jupyter (profiling + cleaning)               |
| Report generation | reportlab                                    |

---

## Baseline metrics (valid analysis window)

| Metric             | Value           |
|--------------------|-----------------|
| Unique orders      | 65,752          |
| Order-line items   | 180,519         |
| Total sales        | $36,784,734.31  |
| Total profit       | $3,966,902.97   |
| Overall margin     | 10.79%          |
| Avg order value    | $559.45         |

Valid window: **2015-01-01 → 2017-09-30** (Oct 2017 onward is synthetic).

---

## Read the full report

📄 **[final_report.pdf](./final_report.pdf)**

34 pages covering:

- Full Phase 1–12 workflow
- All 8 investigations in detail
- All 9 forensics findings with evidence
- Honest conclusion about what the dataset can and cannot support

---

## Lessons learned

1. **Time-box investigations.** I chased the 21% loss-making orders too long before realizing the dataset itself was synthetic.
2. **Not every dataset deserves interpretation.** Knowing when to stop is the real skill.
3. **Killing hypotheses is as valuable as finding them.** Five hypotheses eliminated with data.
4. **Honest reporting beats impressive charts.** A dashboard of synthetic data is a lie.

---

## Author

Built end-to-end as a portfolio investigation:

> Business requirements → warehouse → validation → 8 investigations → forensics → honest report.

---

*Most analysts build dashboards. This is a data forensics investigation.*
