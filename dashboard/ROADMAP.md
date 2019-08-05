# Consult Frontend

# Development Notes

[X] Generalise Observation Service call with API
[X] Use Obs service in vitals calls (comment out)
[X] Stub out sample-data stubs using the Plot HTML for HR and BP
[X] Stats generation for sample-data using existing code
[] Create Consult package
[] BP plot widgetah
[] HR plot widget
[] ECG Plot???
[] Graph Granularity for time.
[] Day-Night Vertical Grids on plots
[] Bar versus Line Charts
[] Base Info Box htmlwidget
[] Implement the 5 vitals widgets
[] Mood Grid Widget
[] Observation POST Service Call in services API
[] Input from Mood widget calls Observation POST
[] CSS Colors and Font and Button Sizing
[] Summary Vitals Selector
[] Time Logic for QuestionnaireResponses form
[] QuestionnaireResponses HTML form in Mood tab
[] QuestionnaireResponses Service Call
[] Risk People Plots Widget (two Widgets from screenshot)
[] Risk data / or intervention.csv data API? (tbd)
[] Recommendations List HTML
[] Recommendations data API? (tbd)
[] Feedback Textbox on Feedback tab
[] ClinicalImpressions service API call
[] ClinicalImpressions list and Notes retrieval
[] Config via Env Variable and Tabs
[] Logging service - API call? (tbd)

# Tiers of Design (level of design)

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
