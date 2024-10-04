# Mbin-Docs

This repo is for building and running the documentation website, that is hosted on [docs.joinmbin.org](https://docs.joinmbin.org). The documentation this is building is coming from the mbin repos [docs folder](https://github.com/MbinOrg/mbin/tree/main/docs)

The docs are built using [Docusaurus](https://docusaurus.io/) and [Redocusaurus](https://github.com/rohit-gohri/redocusaurus).

### Installation

For running this site you need to have an [Mbin](https://github.com/mbinOrg/mbin) repository, where our docs are hosted. The update script takes care of copying over docs and images and generating an open-api json for generating the api docs.

```bash
npm ci
bash update_and_build.sh -d YOUR_MBIN_REPO
```

The repo that is linked will by default fetch and pull changes from the main branch. If you want to use another branch you can specify that by `-b BRANCH`.
It will only build the docs when there were changes in the branch, if you want to force it to rebuild the docs add a `-f`.  
Use the `-s` flag to skip the production build and only update the docs (useful for local development).

### Local Development

```bash
npm start
```

This command starts a local development server and opens up a browser window. Most changes are reflected live without having to restart the server.

### Build

```bash
npm build
```

This command generates static content into the `build` directory and can be served using any static contents hosting service.
