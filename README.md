<p align="center">
    <img src="./logo.png" alt="" width="300"/>  
</p>

# ferdi-server-docker
This is a dockerized version of Ferdi server running on Alpine linux.

## Installation

Pull the docker image:

    docker pull xthursdayx/ferdi-server-docker

	docker create \
	  --name=ferdi-server \
	  -e NODE_ENV=development \
	  -e DB_CONNECTION=sqlite
	  -e DB_HOST=<yourdbhost> \
	  -e DB_PORT=<yourdbPORT> \
	  -e DB_USER=<yourdbuser> \
	  -e DB_PASSWORD=<yourdbpass> \
	  -e DB_DATABASE=adonis \
	  -e IS_CREATION_ENABLED=true \
	  -e CONNECT_WITH_FRANZ=true \
	  -p 6875:80 \
	  -v <path to data>:/config \
	  --restart unless-stopped \
	  xthursdayx/ferdi-server-docker

Run the docker image and create your container:

    docker run --name='ferdi-server' -p '3333:80' -v '/mnt/cache/appdata/ferdi-server':'/usr/src/app' 'xthursdayx/ferdi-server-docker' 


# ferdi-server
Unofficial Franz server replacement for use with the Ferdi Client.

## Why use a custom ferdi-server?
A custom ferdi-server allows you to experience the full potential of the Ferdi client. It allows you to use all Premium features (e.g. Workspaces and custom URL recipes) and [adding your own recipes](#creating-and-using-custom-recipes).

## Features
- [x] User registration and login
- [x] Service creation, download, listing and removing
- [x] Workspace support
- [x] Functioning service store
- [x] User dashboard
- [ ] Password recovery
- [ ] Export/import data to other ferdi-servers
- [ ] Recipe update

## Setup
1. After building this container you will need to edit the [configuration](#configuration) to suit your needs.

## Configuration
franz-server's configuration is saved inside the `.env` file. Besides AdonisJS's settings, ferdi-server has the following custom settings:
- `IS_CREATION_ENABLED` (`true` or `false`, default: `true`): Whether to enable the [creation of custom recipes](#creating-and-using-custom-recipes)
- `CONNECT_WITH_FRANZ` (`true` or `false`, default: `true`): Whether to enable connections to the Franz server. By enabling this option, ferdi-server can:
  - Show the full Franz recipe library instead of only custom recipes
  - Import Franz accounts

## Importing your Franz account
ferdi-server allows you to import your full Franz account, including all its settings.

To import your Franz account, open `http://[YOUR FERDI-SERVER]/import` in your browser and login using your Franz account details. ferdi-server will create a new user with the same credentials and copy your Franz settings, services and workspaces.

## Creating and using custom recipes
ferdi-server allows to extends the Franz recipe catalogue with custom Ferdi recipes.

For documentation on how to create a recipe, please visit [the official guide by Franz](https://github.com/meetfranz/plugins/blob/master/docs/integration.md).

To add your recipe to ferdi-server, open `http://[YOUR FERDI-SERVER]/new` in your browser. You can now define the following settings:
- `Author`: Author who created the recipe
- `Name`: Name for your new service. Can contain spaces and unicode characters
- `Service ID`: Unique ID for this recipe. Does not contain spaces or special characters (e.g. `google-drive`)
- `Link to PNG/SVG image`: Direct link to a 1024x1024 PNG image and SVG that is used as a logo inside the store. Please use jsDelivr when using a file uploaded to GitHub as raw.githubusercontent files won't load
- `Recipe files`: Recipe files that you created using the [Franz recipe creation guide](https://github.com/meetfranz/plugins/blob/master/docs/integration.md). Please do *not* package your files beforehand - upload the raw files (you can drag and drop multiple files). ferdi-server will automatically package and store the recipe in the right format. Please also do not drag and drop or select the whole folder, select the individual files.

### Listing custom recipes
Inside Ferdi, searching for `ferdi:custom` will list all your custom recipes.

## License
ferdi-server is licensed under the MIT License
