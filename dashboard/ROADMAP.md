# Consult Frontend

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
