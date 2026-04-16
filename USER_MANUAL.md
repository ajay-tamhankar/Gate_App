# GateReco User Manual

This manual reflects the current app behavior found in the codebase on April 13, 2026.

## 1. Purpose of the App

GateReco is a warehouse operations app used to:

- record gate entries and gate exits
- verify and approve incoming material records
- create GRNs for verified gate entries
- review reconciliation outcomes between gate entries and SAP/GRN data
- export operational and exception reports

The app is responsive and supports both desktop and mobile layouts. The screen arrangement changes by device size, but the core workflows stay the same.

## 2. User Roles and Access

The app changes its dashboard, navigation, and available actions based on user role.

| Role | Main Access |
| --- | --- |
| Gate Security | Dashboard, Gate Entry, Reports |
| Warehouse Executive | Dashboard, Gate Entry (Pending GRNs), Reconciliation Exceptions, Reports |
| Warehouse Manager / WH Mgr | Dashboard, Gate Entry, Reconciliation Review, Reports, Change Password, GRN Import |
| Admin | Dashboard, Gate Entry, Reconciliation Review, Reports, Change Password, GRN Import |

### Important note on Gate Security access

In the current routing setup, Gate Security users are redirected away from the Reconciliation module. Even though a security reconciliation view exists in code, it is not part of the reachable main navigation today.

## 3. Signing In and Session Basics

### Login

On the login screen:

1. Enter your `Username`.
2. Enter your `Password`.
3. Click `Continue`.

If either field is blank, the app asks you to enter both values.
If login fails, the app shows the error returned by the API or a fallback login failure message.

### Logout

Most screens include a logout action in the top app bar. Use this when you want to securely end the session.

### Change Password

`Change Password` is available from the dashboard only for:

- Admin
- Warehouse Manager
- WH Mgr

Required fields:

- Current Password
- New Password
- Confirm New Password

Rules:

- new password must be at least 6 characters
- confirmation must match the new password

## 4. Main Navigation

Depending on role, the bottom navigation bar or desktop sidebar shows:

- `Dashboard`
- `Gate Entry`
- `Reconciliation`
- `Reports`

Desktop users see a left sidebar.
Mobile users see a bottom navigation bar.

## 5. Dashboard

## 5.1 Gate Security Dashboard

Gate Security users land on `Operations Dashboard`.

What you see:

- welcome banner with user identity details
- `Entries (Today/Month)`
- `Gate In`
- `Gate Out`
- `Gate Entry Activity (Last 7 Days)` chart
- `Turnaround Time (TAT)` card for Gate TAT and Dock TAT

Use the refresh icon to reload dashboard data.

## 5.2 Warehouse Executive Dashboard

Warehouse Executive users land on `Warehouse Dashboard`.

What you see:

- `Today Overview`
- `Pending GRNs`
- `Today's Entries`
- `Reconciliation Snapshot (Today)`
- quick link: `View Pending GRNs`

The reconciliation snapshot shows:

- Matched
- Pending
- Exception

## 5.3 Manager / Admin Dashboard

Warehouse Manager, WH Mgr, and Admin users land on `Manager Dashboard`.

What you see:

- `Import GRN Data` card
- `KPI Overview`
- `Reconciliation Overview`
- `Approval Overview`
- quick link: `Open Review Queue`

The KPI section can include:

- Total Gate Entries (Today/Month)
- Gate In
- Gate Out
- Total GRN Posted
- Pending GRN Count
- Quantity Mismatch Cases
- Duplicate GRN Cases
- pending GRN aging buckets

The Reconciliation Overview shows:

- Total Exceptions
- Missing GRN
- Mismatch
- Field Issues
- a short list of unresolved reconciliation records

The Approval Overview shows:

- Pending Approval
- Exceptions
- Approved Today

## 6. Gate Entry Module

The Gate Entry module behaves differently by role.

- Gate Security, Manager, WH Mgr, and Admin see the general gate entry management view.
- Warehouse Executive sees the warehouse pending GRN view.

## 6.1 Gate Entry List Page

Page title: `Gate Entry Management`

Main functions:

- refresh the list
- search records
- filter records
- open details
- create a new gate entry if you are Gate Security
- load more records when pagination is available

Search box checks:

- challan number
- LR number
- vendor
- vehicle

Filter options:

- All
- Gate In
- Gate Out
- Today
- Yesterday
- This Week

Summary cards show:

- Gate In
- Gate Out
- Today
- Yesterday

Pagination area shows:

- how many records are loaded
- `Load More` when additional pages exist

## 6.2 Creating a New Gate Entry

Only Gate Security users can create a gate entry from this page.

To create a record:

1. Open `Gate Entry`.
2. Click `Create Gate Entry` or `New Gate Entry`.
3. Select `Gate Status`:
   - `Gate In`
   - `Gate Out`
4. Fill the invoice/challan section.
5. Fill vendor and transport details.
6. Optionally attach a file.
7. Click `Confirm Gate Entry`.

### Fields in the create form

#### Gate Information

Each invoice/challan row contains:

- Invoice/Challan Number
- Invoice Date
- PO Number
- Part Number
- Quantity
- UOM

You can use `Add Invoice/Challan` to add more rows.

### Challan validation rules

- at least one challan is required
- duplicate challans inside the same entry are blocked
- the app checks challan uniqueness against existing records
- if a challan already exists, the form shows the existing entry reference
- you can open the existing record from the validation message

By default the challan field allows numeric style input. The toggle icon on the first challan field lets the user allow alphanumeric challans when needed.

### Vendor and transport fields

Required fields:

- Vendor Code
- Vendor Name
- Driver Contact No
- Transporter Name
- Vehicle Number

Other field:

- LR Number

Vendor behavior:

- when Vendor Code loses focus, the app attempts vendor lookup
- if found, Vendor Name is auto-filled and becomes read-only
- if not found, the app allows manual vendor name entry
- manual vendor name entry supports suggestions while typing

Driver contact validation:

- required
- must be 10 to 15 digits

### Attachments

Use `Browse Files` to select an attachment.

Behavior:

- attachment is optional
- selected file name is shown in the form
- you can remove the selected file before submission

### Create form submission rules

The form will not submit if:

- challan validation is still in progress
- no challan is entered
- duplicate or invalid challans remain
- no invoice entry is filled
- required fields are missing

Success message:

- `Gate Entry successfully created!`

## 6.3 Editing an Existing Gate Entry

Editing is available from the detail screen for:

- Warehouse Manager
- WH Mgr
- Admin

Editable fields in update mode include:

- challan number
- vendor information
- LR number
- driver contact
- vehicle number
- transporter
- material name
- PO number
- quantity
- optional attachment

Success message:

- `Gate Entry successfully updated!`

## 6.4 Gate Entry Detail Screen

Page title: `Gate Entry Details`

The detail screen shows:

- challan number
- gate direction
- current status
- entry time
- vendor and transporter information
- vehicle and driver information
- item list with PO, quantity, and UOM
- gate entry number
- created by
- gate out time and gate out by, if available

### Attachment viewing

If attachments exist, the screen shows them with a `View` action.
Attachments are opened externally using the attachment URL from the backend.

## 6.5 Gate Entry Statuses

The general gate entry flow currently uses these status labels:

| System Status | User-facing Meaning |
| --- | --- |
| `inward_created` | Pending |
| `verification_pending` | In Review |
| `approved` | Approved |
| `closed` | Closed |

## 6.6 Gate Entry Actions by Role

### Verify

Visible when:

- status is `inward_created`
- role is Warehouse Executive, Warehouse Manager, WH Mgr, or Admin

### Approve

Visible when:

- status is `verification_pending`
- role is Warehouse Manager, WH Mgr, or Admin

### Close

Visible when:

- status is `approved`
- role is Warehouse Manager, WH Mgr, or Admin

### Edit Entry

Visible for:

- Warehouse Manager
- WH Mgr
- Admin

### Gate Out

Visible when:

- the record is a Gate In entry
- gate-out time is still empty
- status is not `closed`
- role is Gate Security, Warehouse Executive, Warehouse Manager, WH Mgr, or Admin

When the user clicks `Gate Out`, the app asks for confirmation and allows optional remarks.

Success message:

- `Gate out recorded`

## 7. Warehouse Executive Flow

Warehouse Executive users see a warehouse-specific gate entry experience focused on pending GRNs.

## 7.1 Pending GRN List

Page title:

- `Pending GRNs`

The list shows summary records with:

- Gate Entry No
- Vendor
- Vehicle
- PO
- Date
- Status

Tap a record to open details.

## 7.2 Verifying a Pending GRN Entry

In the warehouse detail view, executives can verify the entry before GRN creation.

Fields used during verification:

- Vendor Name
- Vehicle Number
- PO Number
- Remarks

Rules:

- Vendor Name is required
- Vehicle Number is required
- PO Number is required

Actions:

- `Verify`
- `Save Verification`
- `Cancel`

If the record is already verified, the page shows that clearly.
If GRN is already created, verification is locked.

## 7.3 Creating a GRN

After verification, executives can click `Create GRN`.

The GRN form shows one section per item with:

- Material Name
- Received Qty
- Accepted Qty
- Rejected Qty

Optional field:

- Remarks

Validation rule:

- `Accepted + Rejected must equal Received`

Success message:

- `GRN submitted successfully`

If GRN is already complete, the detail screen shows that GRN has already been created.

## 8. Reconciliation Module

The Reconciliation experience differs by role.

## 8.1 Warehouse Executive Reconciliation View

Warehouse Executive users see `Reconciliation Exceptions`.

What the page includes:

- list of actionable exceptions
- item count in desktop view
- record detail view
- import history panel when imports happened in the current session

Each exception item can show:

- Status
- Gate Entry
- Matched GRN
- Description
- Reconciled At

### Resolve behavior

The screen shows a `Resolve` action, but resolution is allowed only for manager-like roles. If a user without permission attempts it, the app shows an access denied message.

### Import SAP GRNs

The `Import SAP GRNs` action is only available to Admin and Warehouse Manager-like users in this view.

Import flow:

1. Click `Import SAP GRNs`.
2. Choose the file.
3. Confirm whether `Run Reconciliation` should happen immediately.
4. Click `Import`.

The page keeps a session-level import history list with:

- file name
- timestamp
- success or failure icon
- message

## 8.2 Manager / Admin Reconciliation Review

Manager-like users see `Reconciliation Review`.

What the page includes:

- hero summary with showing/total counts
- summary cards for Matched, Exceptions, Resolved, and Open
- search and status filters
- record list
- detail view for each record
- pagination with `Load More`

Search checks:

- gate entry number
- reason
- reason code
- matched GRN
- display status

Filter options:

- All
- Matched
- Exception
- Resolved
- Open

## 8.3 Reconciliation Detail

The detail page shows:

- Gate Entry Info
- Reconciliation Result
- Status
- Matched GRN
- Qty Variance
- Reason Code
- Reason
- Resolution Notes
- attachments from the linked gate entry

## 8.4 Reconciliation Status Meanings

Common statuses handled by the current UI:

| Status | Meaning in UI |
| --- | --- |
| `matched` | Successfully matched |
| `pending_grn` | GRN still pending |
| `grn_not_posted` | GRN missing or not posted |
| `quantity_mismatch` | Quantity mismatch |
| `duplicate_grn` | Duplicate GRN issue |
| `wrong_po_material` | PO/material mismatch |

## 9. GRN Import Card on Manager Dashboard

Manager-like users also have an import card directly on the dashboard.

Supported file types:

- CSV
- XLSX

Required columns shown by the UI:

- `poNumber`
- `materialCode`
- `grnNumber`
- `postingDate`

Optional behavior:

- `Auto-run Reconciliation`

Typical steps:

1. Click `Choose CSV/XLSX File`.
2. Review the selected file name.
3. Turn `Auto-run Reconciliation` on or off.
4. Click `Upload`.

The card shows upload progress and a success or error snackbar.

## 10. Reports Module

Page title: `Reports & Exports`

All main user roles can access Reports from navigation.

## 10.1 Available Report Types

- Gate Entry Register
- GRN Reconciliation Report
- Exception Report

## 10.2 Filters and Search

The report toolbar includes:

- free-text search
- report type selector
- date range picker
- clear search button
- Excel export
- PDF export

Default date range:

- last 7 days

Search scope by report:

- Gate Entry Register: vendor, PO, challan, gate entry number
- GRN Reconciliation Report: vendor, PO, challan, gate entry number, GRN-related fields
- Exception Report: gate entry number, PO, status, description

The page also shows active filter chips for:

- date range
- search text

## 10.3 Report Preview and Summary

Before export, the page shows preview data and summary cards.

### Gate Entry Register summary

- Total Entries
- Gate In
- Gate Out
- Total Qty

Preview columns include:

- Gate Entry No
- Direction
- Invoice / Challan No
- PO No
- LR No
- Date And Time
- Material
- Qty
- Vendor
- Transporter
- Vehicle No
- Status

### GRN Reconciliation Report summary

- Total Records
- Matched
- Exceptions
- Pending
- Qty Diff Total

This preview is wide and includes many SAP-related columns such as:

- Gate Entry No
- GRN No
- PO No
- Challan No
- Matched Status
- Qty Diff
- Vendor Name
- Reconciled At
- Material
- Posting Date
- Status
- Aging
- MDR

### Exception Report summary

- Total Exceptions
- Open
- Resolved

Preview columns include:

- Gate Entry No
- Exception Type
- Status
- Date

## 10.4 Exporting Reports

Use:

- the green button for Excel
- the red button for PDF

Success messages:

- `Excel saved to Downloads folder. Check your File Manager.`
- `PDF saved to Downloads folder. Check your File Manager.`

If export fails, the app shows `Export Failed: ...`.

## 11. Common Messages and Behaviors

Examples of built-in messages:

- `Please wait, checking challan...`
- `At least one challan is required`
- `Please fix duplicate/invalid challans`
- `Vendor not found. You can enter vendor name manually.`
- `Please verify before creating GRN`
- `Verification is locked because GRN is already created.`
- `No attachments uploaded yet.`
- `No records found`

## 12. Troubleshooting Guide

### I cannot see the Reconciliation tab

Possible reasons:

- you are logged in as Gate Security
- the router is currently configured to redirect Gate Security users away from Reconciliation

### I cannot change the password

Possible reason:

- only Admin and Warehouse Manager-like roles can access `Change Password`

### The challan is rejected as duplicate

What to do:

- use the provided link to open the existing gate entry
- confirm whether the challan has already been recorded
- correct the challan number if it was typed incorrectly

### I cannot create a GRN

Possible reasons:

- the gate entry is not verified yet
- the GRN for that record is already completed

### I cannot verify a warehouse entry

Possible reasons:

- mandatory verification fields are empty
- the record is locked because GRN is already created

### A report export did not appear

What to check:

- look in the Downloads folder
- retry with a smaller date range if the dataset is large
- check whether an export failure snackbar was shown

## 13. Recommended Operating Sequence

For a typical inbound material process, the intended flow is:

1. Gate Security creates the gate entry.
2. Warehouse Executive opens the pending GRN record.
3. Warehouse Executive verifies vendor, vehicle, PO, and remarks.
4. Warehouse Executive creates the GRN.
5. Manager/Admin reviews dashboards and reconciliation outputs.
6. Manager/Admin uses Gate Entry actions such as approve or close when available.
7. Users export reports when they need operational or audit-style output.

## 14. Notes for Training and Handover

This manual is based on the current Flutter UI and controller logic. If backend rules, route access, or screen behavior change later, this manual should be revised to stay aligned with the live application.
