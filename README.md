sudo docker build -t openanalytics/shinyproxy-template .
sudo docker run -it -p 3838:3838 openanalytics/shinyproxy-template

===

ssh -L 57329:localhost:57329 martin@consult-test-environment

http://localhost:57329/shinydocs/consult-demo/consult_hcp/
http://localhost:57329/shinydocs/consult-demo/patient-demo/
