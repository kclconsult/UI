# Consult Frontend Development

# Backlog

## Essential
- [ ] getRecommendations() -> server-side stub
- [ ] Randomise Tip ordering (option - client-side)
---
- [ ] Blood Pressure Alerts from Dialog Manager (from Isabel and Panos)
- [ ] Graph Granularity for time - Last 4 Hrs, Last Day, Last Week
---
- [ ] Env. variable for StartTimestamp (i.e. presumedly the start time of the trial)
- [ ] Activate Live (i.e. latest time) time for EndTimestamp /or/ EndTimeStamp
- [ ] Live Data app life-cycle - how will the data update itself?
- [ ] updateFeedback data to refresh the Feedback listing
---
- [ ] Synchronise sample-data/
- [ ] USE_SAMPLE_DATA environment option
- [ ] Sample-Data debug options
---
- [ ] Update run.R with pre-flight checks
- [ ] DASHBOARD_DEBUG Config to turn on debugging panels
- [ ] DASHBOARD_ACTIVE_TABS Config via Env Variable and Tabs
- [ ] Documentation in README.md for Environment Variables
---
- [ ] observeEvent (init=FALSE) - prevent of running observeEvent upon initialisations (i.e. TextArea)
- [ ] Tab Buttons for Feedback Sidebar (remove runjs code, use data-toggle Bootstrap)
---
- [ ] Update ECG data from API call for sample-data
- [ ] ECG updated to plot last 1000 lines
---
- [ ] Error Handling and Notification when Message Passer is un-reachable (Log on Server)

## Nice to have
- [ ] Bar versus Line Charts
- [ ] Day-Night Vertical Grids on plots
- [ ] PHQ Forms - easier Choice buttons (Checkboxes?) - tap is tough
- [ ] Tablet: Show who is signed in on Mast
- [ ] Logging service captures poke stream of user
- [ ] ClinicalImpressions Notes Appication (Scrollable Sidebar)
- [ ] Notification Alerts (dismissable) Overlay (icon and color)
- [ ] Connectivity Indicators for SummaryBox
- [ ] Badges for Tabs (or InfoBoxes)

## Done
- [X] Update cates/intervention plots
- [X] Initialize active Stop Smoking first intervention
- [X] Separate the button New Feedback ("Create New Feedback") from the list of Previous feedback
- [X] Title the list "View Previous Feedback"
- [X] mv Feedback into data$
- [X] make the Feedback listing reactive
- [X] Feedback Sideback data-toggle to highlight
- [X] Clean-up Mood Timing Logic
- [X] Move Mood Tab getting data into data$ reactiveValues
- [X] Mood Grid - user feedback, confirm the selection
- [X] <hr /> btw Tips/Recommendations
- [X] Risk Pull-down menu convert to Buttons
- [X] Update People Plots from Isabel - figure out the People Plot sizing
- [X] Partial params submission for PHQ2 only
- [X] OR for PHQ2->PHQ9
- [X] Mood Grid: All 16 images on the same screen (size them the same - landscape)
- [X] Thumbnails for Moods to be displayed in the Summary Box
- [X] Remove the Mood Text in the Summary Box
- [X] Send client-side effectiveTime on POSTs to Server
- [X] Logging service - API - logging function logs Tab selections
- [X] Fix ClinicalImpressions Refreshing upon submit
- [X] Tablet: Feedback, side-bar for previous feedback
- [X] Notes (ClinicalImpressions) App
- [X] ClinicalImpressions List Retrieval from MP API
- [X] Summary Boxes are Buttons to the Data Screens as well.
- [X] Update SummaryBoxes from Panos
- [X] EPSRC Logo
- [X] Remove "Summary" -> Summary, Home Icon.
- [X] Tabs all same widths, or Use the entire length of the top Bar.
- [X] Summary boxes sized to fit within the screen height.
- [X] Test on Tablet, Sizing and Interface with the Chat (2/3 sizing)
- [X] Tablet: Summary Boxes Viewing without Scrolling
- [X] Tablet: Shrink MAST
- [X] Tablet: One Row of tabs
- [X] Tablet: Feedback, textarea smaller with visible SUBMIT button
- [X] PHQ9 Form
- [X] QuestionnaireResponses API Service Call
- [X] PHQ2/9 Logic with Debug Trigger
- [X] PHQ9 Q10 logic
- [X] PHQ9 submit button logic
- [X] Clear PHQ9 form upon submit
- [X] Recommendations List HTML (Use Alerts with Icons or Media Listing)
- [X] Risk People Plots Static - Selector Based on Intervention
- [X] Implement data.R module - move loadDataX and statsX into...
- [X] Alert Logic for BP based on code
- [X] BP Statistics in SummaryBox (latest value / mean over the latest values)
- [X] HR Statistics in SummaryBox (latest value / mean over the latest values)
- [X] ECG Statistics in SummaryBox (number of samples gathered)
- [X] Observation POST Service Call in services API
- [X] Input from Mood widget calls Observation POST
- [X] Mood Statistics in SummaryBox (latest value)
- [X] Feedback Text-box on Feedback tab
- [X] ClinicalImpressions service API call
- [X] QuestionnaireResponses HTML form in Mood tab (put a sub-nav for now)
- [X] PHQ2 Form
- [X] Remove Pain SummaryBox
- [X] SummaryBox DefaultColor
- [X] SummaryBox Icon
- [X] Generalise Observation Service call with API
- [X] Use Obs service in vitals calls (comment out)
- [X] Stub out sample-data stubs using the Plot HTML for HR and BP
- [X] Stats generation for sample-data using existing code
- [X] Create Consult package
- [X] BP plot widgetah
- [X] HR plot widget
- [X] ECG Plot???
- [X] Base Info Box htmlwidget
- [X] Implement the 5 vitals widgets
- [X] Mood Grid Widget
- [X] CSS Colors and Font and Button Sizing

# 5-8-2019 - Further Inquiries and Support Requests

## Data Analysis

- Observation Data Round-up (Verify with live API?)
  Code      | What                | Columns (from sample-data)
  ------------------------------------------------------------------------------
  85354-9    | Blood pressure      | "c271649006" "c271650006" "c8867h4" "datem" "date.month" "time" "weekday"
  8867-4    | Heart rate          | "c40443h4" "c8867h4" "c82290h8" "datem" "date.month" "time" "weekday"
  131328    | ECG                 | wtf (see below)???
  285854004 | Recorded emotion    | ???

- Does Pain Observation Data exist? No, remove from the Summary Box

- Observation Data for ECG
  - ecg.csv in sample-data is not in data.table format.  Is this representative of what the MessagePasser returns? Yes, it is.  Parsing as tuples

- ECG timeline - 5 seconds = 1000+ points...
  - What is desired to show here?  
  - Live ECG?  Need to profile refreshing every 1-5 seconds with deployment.
  * don't know? Tabled
  - Choose a Time to inquire about the ECG.

- Summary Boxes
  X Options: Last 4 hours, Last 24 hours, Last Week?/Month?
  - Just show: Last Values Recorded.
  - Device Connection Problem Badge.
  3 Levels of Display: Green | Orange | Red
  - Blood Pressure - mean number?
  - Heart Rate - mean number?
  - ECG - Number? or Status?  Is there an Interpretation?
    * Don't know: what the interpretation? Grey all the time.
    * Connectivity of the box?
  X Pain - What maps to levels 1-3?
  - Mood - 3 Levels Good | Meh | Bad. Interpretation from self-reporting 16 grid?

- QuestionnaireResponses PHQ9 values and Form Guidance:
  Field                Description
  ------------------------------------------------------------------------------
  id 	                 Resource ID *** Generates itself ***
  subjectReference     Patient ID a.k.a. SHINYPROXY_USERNAME
  effectiveDateTime    Timestamp of response, *** auto-generated ***
  LittleInterest 	     PHQ9 score for LittleInterest
  FeelingDown 	       PHQ9 score for FeelingDown
  TroubleSleeping  	   PHQ9 score for TroubleSleeping
  FeelingTired 	       PHQ9 score for FeelingTired
  BadAppetite 	       PHQ9 score for BadAppetite
  FeelingBadAboutSelf  PHQ9 score for FeelingBadAboutSelf
  TroubleConcentrating PHQ9 score for TroubleConcentrating
  MovingSpeaking 	     PHQ9 score for MovingSpeaking
  Difficulty 	         PHQ9 score for Difficulty
  TotalScore 	         Total PHQ9 score

## MessagePasser / APIs

- ClinicalImpressions for "Notes" display (by date or some ordering)
  - Listing and Retrieving ClinicalImpression by some ID for display

- Risk assessment for the People Plots (not based on ethnicity)
  * based on intervention.csv file. (i.e. Cate's plot)
  * drop down box to Choose an Intervention.
  - show the Static Plots?

- QuestionnaireResponses prompting time-logic
  - for example know when the last Questionnaire was submitted so that it can be prompted once a week
  - PHQ2 - asked once every 2 weeks.
  - Depending on the answer - give them a PHQ2/9.
  --> 3 MOOD MODES: PHQ2 | PHQ9 | Mood Grid

- Recommendations - list of text based recommendations to be displayed
  - recommendation format: "timestamp" (to sort recommendation) | "icon" (visual?) | "recommendation" (text)
  X - STATIC TEXT OF Recommendations

- Dashboard Logging service:
  - generic event format: "timestamp (datetime string)" | "event (String)" | "details (String)"

## Dev-Ops
- Sys.Environment variable:
  "DASHBOARD_ACTIVE_TABS" = comma separated list of tabs
  full-set: "summary,hr,bp,ecg,risk,recommendations,mood,feedback"
  default (if no environment variable is present): "???"

# 29/7/2019 - Tiers of Design (level of design)

1. User Study Patients (Minimal Level)
2. GP Design / Capabilities (Hypothetical)
4. All Ideas

# Tab / Features
* Tabs needs to be able to be turned ON/OFF
- Configuration via a System Environment Variable, comma-separated list.

Summary (1)
Vitals Observations -
  Based on codes
   Isabell will have a list of codes of the observation being requested (e.g. Blood pressure: 85354-9)):
   https://github.kcl.ac.uk/pages/consult/message-passer/#api-Observations-GetObservations

  Heart Rate (1)
  ECG (1)
  Blood Pressure (1)
  * Levels of Granularity to View the Graphs (Buttons to select 1 day, 3 day, week)
  * Line vs. Bar (User Option)
  * day/night periods: Day (6-12) | Day (12-6) | Day (6-12) | Night (12-6)

Mood (1) - zip file emotion images (emailed),
   API service (Github Documentation for the Message Passer):
   https://github.kcl.ac.uk/pages/consult/message-passer/#api-Observations
   - 285854004 	String 	Recorded emotion (based on the Mood Grid)

  * QuestionnaireResponses - HTML Form to submit a PHQ9 depression screening responses form.
  - need to ask Isabelle for values and the format of the form.
  - might have to be asked once a week, as part of the Mood's Tab.

Risk (1) (former "Recommendations" in design documentation) - People Plots
- Risk of secondary stroke
- based on ethnicity, age, gender

Recommendations (aka Notifications) (4)
- Text output from Arg Engine (not present when the Chatbot is not present)
- Needs to be turned ON and OFF

X FAQ - No.
X Medication - No.

Feedback (4) - Notes Application (text field, that is time-stamped).
(Github Doc: https://github.kcl.ac.uk/pages/consult/message-passer/#api-ClinicalImpressions-Add)
- Patient ID = Shiny Username
- Clinical Impressions (Needs a GET request )

# Implicit Logging From the Interface
* Needs a logging service
- Log Poke Stream as Time-stamped.
- Log the Tabs that they are selecting.
- Log Actions to the server.

################################################################################
--------------------------------------------------------------------------------
################################################################################

# Front-End Development Priorities:

1. GUI reflects the Design Document
  a. Premise: R (in Shiny) awkward UI language.
  b. To Do: Design in JS + React - Component Based GUI which also is compatible with MM
  c. Options for deployment:
     - Plan A - can Shiny serve up app (HTML/JS/CSS) as server?
     - Plan B - new web-server (Express/Node?) to serve up App
     - Plan C - deploy as an Electron(?) Android App.

2. Implement Graphs in App
  a. Premise: 3 Graphs to integrate into app - 3 ggplot calls in Shiny - data provided by backend
  b. To Do: Use D3/D3-based plot lib to implement graphs server side.  Client side allows for ability to tweak graphs w/o re-deploying server-side app.
  c. Options:
     - Plan A - have Shiny server up data in a separate call to client
     - Plan B - new public REST API (Express/Node?) to serve up graph data
  d. Note: Security issues with sending data (more obfuscated?) versus images (less precise?)

3. Integrate Chat, MatterMost (MM) and Front-End App
  a. Premise: MM is React with client library, has a separate server.
  b. To Do: Unify the UI by have a single chat window in the app. Need an option in UI to *not* have chat window up.
  c. Options:
    - Plan A - See if there is a re-usable component in GUI to use in app.
    - Plan B - Hack apart the current web-app client to only have a single chat window.
    - Plan C - Build up a single chat window within the application.

4. Stream-line Login somehow, between the services, the App, and chat (MM)
  a. Options:
    - Plan A - Use the same credentials for LDAP(?)/Shiny R server login and MM chat server.
    - Plan B - Token Authentication(?)

5. Mood Reporting.
  a. Premise: use designed fixed grid of images, and report back which image the user picks for mood.
  b. To Do: API end-point to POST the Mood selection for the user.
  c. Options:
    - Plan A - have Shiny provide a POST response to save the mood and pass along the selection to the appropriate service.  Unclear if Shiny provides flexibility for this.
    - Plan B - public REST API end-point to receive the mood POST and pass along to appropriate service.
