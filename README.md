# Route 40 Motors — Service Booking & Aftersales Platform

An automotive aftersales application built on **SAP BTP ABAP Environment** with the **ABAP RESTful Application Programming Model (RAP)**, **CDS** and **SAP Fiori Elements**, plus an **AI booking summary** prototype.

Route 40 Motors models a multi-site car workshop. A customer's vehicle is booked for service, each booking reserves a spare part at a specific site, and the back end refuses the booking if that part is not in stock at that site. The project also tracks parts deliveries and includes a Saudization (Nitaqat-style) workforce report, reflecting the Saudi market it is themed on.

> Sample data in this repository is fictional.

**Author:** Sharfunisa Shajahan · [GitHub](https://github.com/Nishaweb-developer) · [Portfolio](https://nishaweb-developer.github.io/myworks)

---

## What it does

- **Service bookings**: list report and object page with create, edit and delete.
- **Stock validation**: a server-side validation (`checkStock`) blocks a booking when the part does not exist at the chosen site or is out of stock, on both create and edit.
- **Master data**: vehicles, sites, spare parts (stock is kept per part and per site), technicians.
- **Deliveries**: purchase-order quantity, delivered quantity and open quantity per delivery, with a *Receive Remaining* action.
- **Saudization report**: share of Saudi technicians per department, with a colour band.
- **AI booking summary** (prototype): a Python script that summarizes bookings and drafts customer reminders, with automated output checks. See [AI booking summary](#ai-booking-summary).

## Architecture

Every entity follows the same RAP layering:

```
Database table              ZSVCBOOKING, ZSPAREPART, ZVEHICLE, ZSITE, ZTECHNICIAN, ZDELIVERY, ZINVOICE
      |
Interface view  ZI_*        + behavior definition + behavior pool ZBP_I_* (validations, actions)
      |
Projection view ZC_*        + metadata extension ZME_* (Fiori list and object page layout)
      |
Service definition          ZSD_SVCBOOKING
      |
Service binding             ZSB_SVCBOOKING_V2  (OData V2 - UI)
      |
Fiori Elements app          List Report + Object Page
```

![Service binding with exposed entities](https://github.com/Nishaweb-developer/ABAP_Route40_Motors/raw/main/screenshots/01-service-binding.png)

## Data model

| Table         | Purpose                                                                  | Linked to                            |
| ------------- | ------------------------------------------------------------------------ | ------------------------------------ |
| `ZSVCBOOKING` | One service job: vehicle, part, site, technician, dates, status          | Vehicle, SparePart, Site, Technician |
| `ZVEHICLE`    | Customer vehicles                                                        | Booking                              |
| `ZSPAREPART`  | Stock per part **and** site (key `PART_ID` + `SITE_ID`), price, currency | Booking, Delivery                    |
| `ZSITE`       | Workshop locations                                                       | Booking, Delivery, SparePart         |
| `ZTECHNICIAN` | Technicians: name, nationality, department, join date                    | Booking, Saudization report          |
| `ZDELIVERY`   | Incoming parts against a PO                                              | SparePart, Site                      |
| `ZINVOICE`    | Invoice header table, prepared for e-invoicing (not exposed yet)         | Planned                              |

## Stock validation (`checkStock`)

The validation runs on save. It looks up the part at the booking's site in `ZSPAREPART` and reports an error on the booking if the row is missing or the quantity is zero.

```abap
" Simplified from the behavior pool ZBP_I_SVCBOOKING
SELECT SINGLE qty_stock FROM zsparepart
  WHERE part_id = @booking-PartId
    AND site_id = @booking-SiteId
  INTO @DATA(qty).

IF sy-subrc <> 0.
  " failed + reported: "Part '<id>' not found for site '<site>'"
ELSEIF qty = 0.
  " failed + reported: "Part is out of stock"
ENDIF.
```

### Test results

| Scenario                                                     | Result                                                  | Evidence |
| ------------------------------------------------------------ | ------------------------------------------------------- | -------- |
| Part with stock at the site (P001 / S001)                    | Saves, row written to `ZSVCBOOKING`                     | [![](https://github.com/Nishaweb-developer/ABAP_Route40_Motors/raw/main/screenshots/09-booking-saved-db.png)](https://github.com/Nishaweb-developer/ABAP_Route40_Motors/blob/main/screenshots/09-booking-saved-db.png) |
| Part with zero stock at the site (P002 / S002)               | Blocked: *Part is out of stock*                         | [![](https://github.com/Nishaweb-developer/ABAP_Route40_Motors/raw/main/screenshots/03-out-of-stock-create.png)](https://github.com/Nishaweb-developer/ABAP_Route40_Motors/blob/main/screenshots/03-out-of-stock-create.png) |
| Unknown part (P999 / S001)                                   | Blocked: *Part 'P999' not found for site 'S001'*        | [![](https://github.com/Nishaweb-developer/ABAP_Route40_Motors/raw/main/screenshots/04-part-not-found.png)](https://github.com/Nishaweb-developer/ABAP_Route40_Motors/blob/main/screenshots/04-part-not-found.png) |
| Unknown site (P001 / S999)                                   | Blocked: *Part 'P001' not found for site 'S999'*        | [![](https://github.com/Nishaweb-developer/ABAP_Route40_Motors/raw/main/screenshots/05-site-not-found.png)](https://github.com/Nishaweb-developer/ABAP_Route40_Motors/blob/main/screenshots/05-site-not-found.png) |
| Empty part                                                   | Blocked: *Part '' not found for site 'S999'*            | [![](https://github.com/Nishaweb-developer/ABAP_Route40_Motors/raw/main/screenshots/06-empty-part.png)](https://github.com/Nishaweb-developer/ABAP_Route40_Motors/blob/main/screenshots/06-empty-part.png) |
| Edit an existing booking and move it to a site with no stock | Blocked on save: *Part is out of stock*                 | [![](https://github.com/Nishaweb-developer/ABAP_Route40_Motors/raw/main/screenshots/08-out-of-stock-on-edit.png)](https://github.com/Nishaweb-developer/ABAP_Route40_Motors/blob/main/screenshots/08-out-of-stock-on-edit.png) |
| Lowercase input (`p001`)                                     | Blocked: key lookup is case-sensitive (see limitations) | [![](https://github.com/Nishaweb-developer/ABAP_Route40_Motors/raw/main/screenshots/07-case-sensitive.png)](https://github.com/Nishaweb-developer/ABAP_Route40_Motors/blob/main/screenshots/07-case-sensitive.png) |

### Booking object page

![Booking object page](https://github.com/Nishaweb-developer/ABAP_Route40_Motors/raw/main/screenshots/02-booking-object-page.png)

## Deliveries

Each delivery shows the PO quantity, delivered quantity and open quantity, and offers a *Receive Remaining* action.

![Delivery object page](https://github.com/Nishaweb-developer/ABAP_Route40_Motors/raw/main/screenshots/10-delivery-object-page.png)

## Saudization report

Saudization is Saudi Arabia's policy of raising the share of Saudi nationals in private-sector employment, and **Nitaqat** is the program that measures it and assigns companies a colour band. This report calculates, per department:

```
Saudization % = Saudi technicians / total technicians x 100
```

It is built as three stacked CDS view entities (counts, percentage, band), projected as `ZC_SaudiBand`, exposed as the `SaudiBand` entity, and shown in a Fiori Elements list report with criticality colours.

![Saudization report](https://github.com/Nishaweb-developer/ABAP_Route40_Motors/raw/main/screenshots/11-saudization-report.png)

**Important:** the bands (Red, Low Green, Mid Green, High Green, Platinum) use **illustrative cut-offs** (below 10, 20, 30 and 40 percent, then Platinum), not official Nitaqat thresholds. Real Nitaqat is calculated for a whole establishment, by sector and company size, not per department. The per-department view is a simplification for this demo.

## AI booking summary

This part of the project uses an LLM to summarize service bookings and draft customer reminders. It is split into two parts:

| Part | Status |
|---|---|
| **Python prototype** (`route40-ai-assistant/`) | Working. Runs on exported SAP data, with automated output checks. |
| **ABAP version** (AI button inside the Fiori app) | Built, but blocked. The Fiori app loads and shows the button, but the call to Gemini cannot run from the trial ABAP environment. |

### What the Python prototype does

1. Loads service bookings from `bookings.json` (exported from the Route 40 service).
2. For each booking, sends the record to Google Gemini with rules: use only the facts provided, write "not provided" for missing fields, never name a technician without a value, flag service/part mismatches, and write a customer reminder only for open bookings.
3. Retries automatically when Gemini is busy (`503`), waiting longer each time.
4. Runs checks on each answer and prints PASS or FAIL.

![Python prototype first run](route40-ai-assistant/screenshots/01-python-prototype-first-run.png)

*First run of `summarize.py`: a status summary, a reminder when needed, and PASS/FAIL checks for each booking.*

### The ABAP side

![Booking list with the AI summary field empty](route40-ai-assistant/screenshots/02-fiori-booking-list-ai-summary-empty.png)

*The booking list loads. The AI summary field is empty because the action has not run successfully yet.*

![Booking object page with Generate AI Summary button](route40-ai-assistant/screenshots/03-fiori-object-page-generate-ai-summary-button.png)

*The object page shows Generate AI Summary next to Complete Service.*

![GEMINI_API destination in the destination service instance](route40-ai-assistant/screenshots/06-btp-destination-gemini-api.png)

*The HTTP destination `GEMINI_API` in the destination service instance used by the ABAP environment.*

### What the AI checks found

- **Repeated data mismatch.** Booking B004 is an oil change with a brake pad set. The AI repeated both facts without flagging the mismatch. The second version of the prompt requires flagging it.
- **Lowercase booking ID.** `b028` was not flagged. The check failed, and the prompt now requires flagging it.
- **Internal labels in a customer reminder.** Booking B012's reminder included "Status: Open" and "Vehicle details: not provided", which should not reach a customer. The prompt now forbids this.

### Why the ABAP version is blocked

The ABAP class `ZCL_AI_SUMMARY` calls Gemini through the destination `GEMINI_API`. The call fails before it starts, because ABAP cannot find the destination. The steps tried, and where each one stopped:

| Step | Result |
|---|---|
| Fiori app loads after adding `get_instance_features` | Fixed a `RAISE_SHORTDUMP` |
| Button visible after `FOR_ACTION` annotation | Fixed |
| Destination created in the destination service instance | Created |
| Console test `ZCL_TEST_DEST` | `Destination not found` |
| Debugger | `CX_HTTP_DEST_PROVIDER_ERROR` caused by `CX_A4C_DESTINATION_NOT_FOUND` |
| Destination service instance binding | `Bound Applications (0)`; no binding is possible from this screen |
| Communication arrangement SAP_COM_0276 | App not visible to the trial user; needs the ABAP business role |

![ABAP console reports Destination not found](route40-ai-assistant/screenshots/05-limitation-abap-console-destination-not-found.png)

*The console test returns `Destination not found`, although `GEMINI_API` exists in the destination service instance.*

![Debugger shows CX_A4C_DESTINATION_NOT_FOUND](route40-ai-assistant/screenshots/04-limitation-abap-debugger-destination-provider-error.png)

*In the debugger, the error is `CX_HTTP_DEST_PROVIDER_ERROR` caused by `CX_A4C_DESTINATION_NOT_FOUND`. The Gemini call never starts.*

![Destination service instance with zero bound applications](route40-ai-assistant/screenshots/07-limitation-destination-service-zero-bound-applications.png)

*The destination service instance shows `Bound Applications (0)`.*

![BTP role collection SAP_BR_ADMINISTRATOR](route40-ai-assistant/screenshots/08-limitation-btp-role-collection-sap-br-administrator.png)

*The BTP role collection contains cockpit, destination, and Business Application Studio roles. It does not contain the ABAP business catalog that exposes the Communication Arrangements app. That role has to be assigned inside the ABAP system, which the trial user cannot reach.*

SAP's documentation says the destination-service route is not usable on trial systems, so the ABAP call may not be possible on this account. The Python prototype is the working AI layer until that changes.

Full build history, including every error and fix, is in [`route40-ai-assistant/README.md`](route40-ai-assistant/README.md).

## Tech stack

- SAP BTP ABAP Environment (ABAP Cloud)
- RAP managed scenario: behavior definitions, validations, actions, `strict ( 2 )`
- CDS view entities, projection views, metadata extensions
- OData V2 service definition and binding (UI)
- SAP Fiori Elements (list report and object page)
- Python 3.12, Google Gemini API (AI prototype)
- ABAP Development Tools (Eclipse), abapGit

## Run it yourself

**SAP side**

1. Install the abapGit plugin in ADT and link this repository to a package in your ABAP Environment system, then **Pull**.
2. Activate all objects.
3. Run the seed classes (`ZCL_SEED_*`) with `F9` to load sample vehicles, sites, parts, bookings and technicians.
4. Open the service binding `ZSB_SVCBOOKING_V2`, publish it, select an entity (for example `SvcBooking`) and click **Preview**.

**AI prototype (Python)**

```bash
pip3 install google-genai
export GEMINI_API_KEY="your-key-here"   # never commit this
cd route40-ai-assistant
python3 summarize.py
```

## Known limitations

- The stock lookup is case-sensitive, so `p001` is rejected. Normalising input to upper case is a planned improvement.
- The validation checks stock but does not reduce it, so a booking does not deduct quantity yet.
- Saudization bands are illustrative (see above).
- **AI:** the Python prototype reads an exported file, not a live OData call. The ABAP AI button cannot reach Gemini on this trial (see [The ABAP side](#the-abap-side)).
- **AI:** the checks are pattern-based. A PASS means the basic rules held, not that the answer is correct.
- **AI:** Gemini's free tier has rate and daily limits, and returns `503` when busy.

## Roadmap (planned, not built yet)

- Technician assignment warning when a hire would lower a department's Saudization ratio
- ZATCA-style e-invoice: a "Complete Service" action creating a `ZINVOICE` record with a TLV QR code
- Classic ALV companion report on an on-premise system
- Integration: Cloud Connector, RFC, IDoc and an SAP Cloud Integration flow
- AI booking summary: Python prototype done; ABAP version pending a trial environment that can call external APIs

## About

ABAP_Route40_Motors — Sharfunisa Shajahan
