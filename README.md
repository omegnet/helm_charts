# helm_charts
My Helm Charts

## Host helm charts in you own repo.

Create a new repo in GitHub then clone it
```
git clone git@github.com:omegnet/helm_charts.git
cd helm_charts
mkdir charts      ## copy some charts in this DIR
mkdir .packages
echo ".packages" >> .gitignore
git add .
git commit -m 'Initial Commit'
git push
```
## Create a new branch called gh-pages:
```
git checkout --orphan gh-pages
rm -rf charts
git add . --all
git commit -m 'initial gh-pages'
git push origin gh-pages
```
## Verify your charts and create new packages:
```
git checkout main
helm lint charts/*
for package in $(ls charts); do helm package charts/$package --destination .packages; done
git checkout gh-pages
```
## Go to your username settings and create a personal tocken if you don't already have one. Choose your permissions
https://github.com/settings/tokens
```
export CH_TOKEN=<your token HERE>
cr upload -o omegnet -t $CH_TOKEN -r helm_charts -p .packages
cr index -i ./index.yaml -p .packages -o omegnet -r helm_charts
git add index.yaml
git commit -m "initial index file created"
git push origin gh-pages
```
## Add rour new repo and install your helm releases:
```
helm repo add omegnet https://omegnet.github.io/helm_charts/
helm repo list 
helm repo update
helm search omegnet
helm install omegnet/metrics-server
helm fetch omegnet/nfs-subdir-external-provisioner
```

### Need to update the charts...

