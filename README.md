# UI (ui)

User interface backend.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Before starting, [download and install shiny](https://www.r-project.org/nosvn/pandoc/shiny.html).

### Other service communication

Receives messages from: message-passer ([install](https://github.kcl.ac.uk/consult/message-passer)) ...

Sends messages to: message-passer ([install](https://github.kcl.ac.uk/consult/message-passer)) ...

## Download

(Recommended) [Create an SSH key](https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and clone this repository.

```
git clone git@github.kcl.ac.uk:consult/ui.git
```

(Alternative) Clone this repository using HTTPs, suppling username and password:

```
git clone https://github.kcl.ac.uk/consult/ui.git
```

## Documentation

[View](https://shinyproxy.io).

## Editing

This is an [shiny](https://shiny.rstudio.com/) project. The majority of the logic is contained within [app.R](dashboard/app.R).

Once a file is edited, stage, commit and push changes from the root folder as follows:

```
git add .
git commit -m "[details of changes]"
git push
```

## Building and Running

To run locally, a shiny server (service) is required, with the content of `dashboard` loaded at the appropriate route (e.g. `/srv/shiny-server/dashboard`).

Repository updates can be copied to a location like this using [copy-shiny.sh](copy-shiny.sh).

Environment variables, which are populated during production by ShinyProxy and Docker, should be specified in the shiny server user's R environemnt variable file (`.Renviron`):

```
MESSAGE_PASSER_PROTOCOL=[protocol]
MESSAGE_PASSER_URL=[url]
SHINYPROXY_USERNAME=[patient ID known to the message-passer]
```

Alternatively, `dashboard` can be run from within R using ``runApp("dashboard")``.

Alternatively, the shiny application can be run as a standalone docker image. Uncomment the appropriate lines in [docker-compose.yml](docker-compose.yml), and then run:

```
docker-compose up dashboard
```

## Running the tests

--

## Deployment

In production, login is handled by [ShinyProxy](https://shinyproxy.io), which operates by controlling access to a dockerised version of a Shiny application, which in this case is the CONSULT dashboard.

To dockerise the CONSULT dashboard run

```
./build-docker-image.sh
```

being sure to specify the host information of the [message-passer](https://github.kcl.ac.uk/consult/message-passer) in this file if necessary.

To build and run ShinyProxy so that it can serve a login page, and then subsequently run the dockerised version of the dashboard for each user, run docker-compose:

```
docker-compose build
docker-compose up -d
```

## Built With

* [Shiny](https://shiny.rstudio.com/) - R + webserver
* [ShinyProxy](https://shinyproxy.io) - Shiny authentiction

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/martinchapman/nokia-health/tags).

## Authors

Produced as part of the [CONSULT project](https://consult.kcl.ac.uk/).

![CONSULT project](https://consult.kcl.ac.uk/wp-content/uploads/sites/214/2017/12/overview-consult-768x230.png "CONSULT project")

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

*
