# UI (ui)



## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Before starting, [download and install python](https://www.python.org/downloads/), [pip](https://packaging.python.org/tutorials/installing-packages/#use-pip-for-installing), [virtualenv](https://virtualenv.pypa.io/en/latest/installation/) and [Node.js](https://nodejs.org/en/download/).

### Other service communication

Receives messages from: fhir-server ([install](https://github.kcl.ac.uk/consult/fhir-server/blob/master/README.md)) ...

Sends messages to: data-miner ([install](https://github.kcl.ac.uk/consult/data-miner/blob/master/README.md)), fhir-server ([install](https://github.kcl.ac.uk/consult/fhir-server/blob/master/README.md)), dialogue-manager ([install](https://github.kcl.ac.uk/consult/dialogue-manager/blob/native-js/README.md)), UI ([install](https://github.kcl.ac.uk/consult/UI/blob/shiny-simplified/README.md)) ...

## Download

(Recommended) [Create an SSH key](https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and clone this repository.

```
git clone git@github.kcl.ac.uk:consult/message-passer.git
```

(Alternative) Clone this repository using HTTPs, suppling username and password:

```
git clone https://github.kcl.ac.uk/consult/message-passer.git
```

## Documentation

[View](https://github.kcl.ac.uk/pages/consult/message-passer/).

## Editing

This is an [shiny]() project. The majority of the logic is contained within [app.R](dashboard/app.R).

Once a file is edited, stage, commit and push changes from the root folder as follows:

```
git add .
git commit -m "[details of changes]"
git push
```
## Building and Running

ShinyProxy operates by controlling access to a dockerised version of a Shiny application, which in this case is the CONSULT dashboard.

To dockerise the CONSULT dashboard run

```
./build-docker-image.sh
```

being sure to specify the host information of the [message-passer]() in this file if necessary.

To build and run ShinyProxy so that it can serve a login page, and then subsequently run the dockerised version of the dashboard for each user, run docker-compose:

```
docker-compose build
docker-compose up -d
```

## Running the tests

## Deployment


## Built With

* [ShinyProxy]() -

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
