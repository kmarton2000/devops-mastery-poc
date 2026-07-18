# 1. Add hozzá a hivatalos Jenkins Helm repót
helm repo add jenkins https://charts.jenkins.io
helm repo update

# 2. Hozz létre egy saját, tiszta felülbíráló fájlt (pl. my-values.yaml)
# Nem kell a teljes óriási values.yaml-t bemásolnod, CSAK azt, amit módosítani akarsz!

# Első telepítés esetén:
helm install jenkins jenkins/jenkins -f my-values.yaml --namespace jenkins --create-namespace

# Frissítés (upgrade) esetén:
#helm upgrade jenkins jenkins/jenkins -f my-values.yaml --namespace jenkins

#OC esetén
#oc adm policy add-scc-to-user anyuid -z jenkins -n jenkins