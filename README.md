# DataCo Supply Chain Forensics

### I spent a month analyzing a supply chain dataset. Then I found out it was fake.

**180,519 rows · 53 columns · PostgreSQL star schema · 20 validation tests · 9 forensic findings · 34-page report**

**Start here → [Read the 34-page report](DataCo_Supply_Chain_Analytics_Report_FIXED_FULL_34_PAGES.pdf)**

---

## The short version

I took the public DataCo Supply Chain dataset and ran a full analytics workflow on it:

- Business Requirements Document
- 61-field data dictionary
- Profiling and cleaning notebooks
- Star schema design, with reasoning for each choice
- PostgreSQL warehouse
- 20-test validation suite
- 24 business questions across 8 domains
- 8 structured SQL investigations

Then the evidence stopped adding up:

| What the data claimed | What the evidence showed |
|---|---|
| Real business, many categories | Profit margin sat at ~10-11% in every dimension I sliced |
| Sensible product catalog | Golf balls were filed under "Electronics" |
| Natural discounting | Discount distribution was artificially equalized |
| Normal shipping behavior | Impossible zero-variance patterns |
| Continuous history | A sharp shift to synthetic data from October 2017 onward |

So I stopped interpreting and started investigating.

**Result:** the dataset is a research artifact, not real business data. It can't support real business insights. But the investigation can show exactly *what it can and can't support*, and that is the deliverable.

---

## The 9 forensic findings

| ID | Finding | Status |
|---|---|---|
| F1 | Dataset is a research artifact | ✅ Confirmed |
| F2 | October 2017 onward is synthetic | ✅ Confirmed |
| F3 | Market labels unstable across years | ✅ Confirmed |
| F4 | Margins uniformly ~10-11% across all dimensions | ✅ Confirmed |
| F5 | Categories are randomly assigned | ✅ Confirmed |
| F6 | `order_profit_per_order` may be order-level | ⚠️ Open |
| F7 | $1,500 price anchor in extreme lines | ⚠️ Open |
| F8 | Discount distribution is artificially equalized | ✅ Confirmed |
| F9 | Shipping data is synthetic | ✅ Confirmed |

Each finding follows the same structure: **Claim → Evidence → Interpretation → Limitation.**

---

## What's in this repo

### 📄 Documents
| File | Purpose |
|---|---|
| [DataCo_BRD.pdf](DataCo_BRD.pdf) | Business requirements |
| [DataCo_Source_System_Discovery.pdf](DataCo_Source_System_Discovery.pdf) | How the source data was discovered and understood |
| [DataCo_Data_Dictionary.pdf](DataCo_Data_Dictionary.pdf) | 61-field data dictionary |
| [Full report (34 pages)](DataCo_Supply_Chain_Analytics_Report_FIXED_FULL_34_PAGES.pdf) | Workflow, all 8 investigations, all 9 findings, conclusion |

### 🧪 Profiling & cleaning
| File | Purpose |
|---|---|
| [profiling .ipynb](profiling%20.ipynb) | Data profiling |
| [cleaning (2).ipynb](cleaning%20%282%29.ipynb) | Cleaning |

### 🧠 Modeling & planning
| File | Purpose |
|---|---|
| [00_Mental_Model_of_Data_Modeling.md](00_Mental_Model_of_Data_Modeling.md) | How I reasoned about the model |
| [01_business_model.md](01_business_model.md) | Business model behind the schema |
| [07_00_Business_Question_Map.md](07_00_Business_Question_Map.md) | The 24 business questions across 8 domains |

### 🏗️ Warehouse build (run in order)
| Step | File |
|---|---|
| 1 | [01_schema_setup.sql](01_schema_setup.sql) |
| 2 | [02_check_landing_table.sql](02_check_landing_table.sql) |
| 3 | [03_create_dimensions.sql](03_create_dimensions.sql) |
| 4 | [04_populate_dimensions.sql](04_populate_dimensions.sql) |
| 5 | [05_create_fact_table.sql](05_create_fact_table.sql) |
| 6 | [06_populate_fact_table.sql](06_populate_fact_table.sql) |
| 7 | [07_warehouse_validation.sql](07_warehouse_validation.sql) (20 integrity tests) |

### 🔎 Investigations
| File | Purpose |
|---|---|
| [data_co_sql.sql](data_co_sql.sql) | SQL investigations and forensic findings |

---

## Baseline metrics (valid window only)

Valid window: **2015-01-01 → 2017-09-30**. Everything after is synthetic.

| Metric | Value |
|---|---|
| Unique orders | 65,752 |
| Order-line items | 180,519 |
| Total sales | $36,784,734.31 |
| Total profit | $3,966,902.97 |
| Overall margin | 10.79% |
| Average order value | $559.45 |

---

## Tech stack

| Layer | Tool |
|---|---|
| Warehouse | PostgreSQL (star schema) |
| Data wrangling | Python: pandas, numpy, SQLAlchemy |
| Analysis | SQL: 20-test validation suite + 8 investigations |
| Notebooks | Jupyter (profiling, cleaning) |
| Report generation | reportlab |

---

## What I learned

1. **Time-box investigations.** I chased the 21% loss-making orders for too long before realizing the dataset itself was synthetic.
2. **Not every dataset deserves interpretation.** Knowing when to stop is the real skill.
3. **Killing hypotheses is as valuable as finding them.** Five hypotheses were eliminated with data.
4. **Honest reporting beats impressive charts.** A dashboard of synthetic data is a confident lie.

---

*Built as an end-to-end portfolio investigation: requirements → warehouse → validation → investigations → forensics → an honest report.*

**Pulkit Shrivastava** · [GitHub](https://github.com/pulkitxc) · [LinkedIn](https://www.linkedin.com/in/pulkit-shrivastava-8079a438b)
