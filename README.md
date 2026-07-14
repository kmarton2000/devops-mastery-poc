DevOps Platform Provisioning PoCEz a projekt egy egyedi, lokális Kubernetes / OpenShift (CRC) környezetre tervezett Proof-of-Concept (PoC) platform. Egyetlen konfigurálható Helm chart segítségével indítja el a legnépszerűbb DevOps és CI/CD eszközöket egy közös névtérben.📂 Repository felépítéseA projekt könyvtárszerkezete a tiszta Helm-sablonozási elveket és a moduláris felépítést követi:Plaintextdevops-mastery-poc/
├── devops-tools/                 # A közös Helm chart könyvtára
│   ├── Chart.yaml                # Chart metaadatok
│   ├── values.yaml               # Globális és eszköz-szintű konfigurációk
│   ├── .helmignore
│   └── templates/
│       ├── _helpers.tpl          # Újrahasznosítható Helm sablonfüggvények
│       ├── ingress.yaml          # Közös hálózati behatolási pont (Vanilla K8s)
│       ├── argocd/               # ArgoCD erőforrások (Deployment, Service, RBAC)
│       ├── grafana/              # Grafana vizualizációs szerver
│       ├── jenkins/              # Jenkins CI automatizációs szerver
│       └── kafka/                # Kafka üzenetsor (StatefulSet & Service)
└── README.md                     # Rendszerdokumentáció és üzemeltetési útmutató
🚀 Telepítési útmutató (Vanilla Kubernetes)Ha szabványos Kubernetes környezetben (pl. Minikube, k3d, Docker Desktop) telepítesz, a hálózati elérést a beépített ingress.yaml biztosítja.Bash# 1. Hozzuk létre a dedikált névteret
kubectl create namespace devops

# 2. Dry-run / Template generálás ellenőrzése
helm template devops-deployment ./devops-tools --namespace devops

# 3. Telepítés a klaszterre
helm install devops-deployment ./devops-tools --namespace devops

# 4. Frissítés a values.yaml változása után
helm upgrade devops-deployment ./devops-tools --namespace devops
🔴 OpenShift (CRC) specifikus beállításokOpenShift (CodeReady Containers) környezetben a natív hálózati elosztás nem az Ingress controlleren, hanem a beépített HAProxy Routeren (Route) keresztül valósul meg.1. Szolgáltatások publikálása (Route-ok létrehozása)Az alapértelmezett ClusterIP szolgáltatásokat az alábbi parancsokkal kell exponálni, hogy külső URL-t kapjanak:Bashoc expose service jenkins-service --name=jenkins --port=web -n devops
oc expose service grafana-service --name=grafana -n devops
oc expose service kafka-service --name=kafka -n devops
2. ArgoCD HTTPS / SSL probléma megoldásaAz ArgoCD belső architektúrája megköveteli a titkosított kapcsolatot. Mivel sima HTTP-n keresztül a Route Application is not available hibát adna vissza, az OpenShift routernek kell kezelnie a TLS terminációt az Edge protokoll segítségével:Bash# Töröljük az esetlegesen rosszul létrejött sima HTTP route-ot
oc delete route argocd -n devops

# Létrehozzuk a biztonságos, Edge TLS-sel ellátott Route-ot
oc create route edge argocd --service=argocd-server-service --port=8080 -n devops
A sikeres futtatást követően az ArgoCD elérhetővé válik a biztonságos https://argocd-devops.apps-crc.testing címen.🛠️ Ismert korlátok és Fejlesztési Terv (Roadmap)A platform jelenleg egy stabil Proof-of-Concept fázisban van. A produkciós szintű használathoz az alábbi fejlesztések bevezetése szükséges:ModulProbléma / KihívásTervezett megoldás (To-Do)ArgoCDRBAC jogosultsági problémák a default Service Accounttal.Saját SA implementáció és dedikált RBAC szabályok finomhangolása.KafkaLokális fájlrendszer használata miatt a pod restart adatvesztéssel jár.StatefulSet átalakítása dynamic dynamic volume provisioning (PVC) alapú perzisztens tárolásra.TárhelyAz összes alkalmazás állapota elvész pod-rekreáció során.Persistent Volume (PV) és Persistent Volume Claim (PVC) bevezetése a Jenkins és a Grafana esetében is.KarbantarthatóságAz egyedi YAML-ek folyamatos karbantartást és frissítést igényelnek.A saját sablonok helyett Umbrella Chart struktúra használata, ahol a hivatalos upstream chartokat (ArtifactHub) subchartként húzzuk be dependencyként.🌿 Git Branch StratégiaA projekt jelenlegi verziókezelése az alábbi ágstruktúrát követi:main: Stabil, tesztelt állapot.develop: Folyamatos integrációs ág.feature/setup: Az alapvető infrastruktúra és eszközök konfigurálásáért felelős fejlesztői ág.