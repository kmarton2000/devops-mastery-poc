# DevOps Platform Provisioning PoC

Ez a projekt egy egyedi, lokális Kubernetes / OpenShift (CRC) környezetre tervezett **Proof-of-Concept (PoC)** platform.

Egyetlen konfigurálható **Helm Chart** segítségével indítja el a legnépszerűbb DevOps és CI/CD eszközöket egy közös namespace-ben.

---

# 📂 Repository felépítése

A projekt könyvtárszerkezete a tiszta Helm-sablonozási elveket és a moduláris felépítést követi.

```text
devops-mastery-poc/
├── devops-tools/                 # Közös Helm Chart
│   ├── Chart.yaml                # Chart metaadatok
│   ├── values.yaml               # Globális és eszköz-specifikus konfiguráció
│   ├── .helmignore
│   └── templates/
│       ├── _helpers.tpl          # Újrahasznosítható Helm sablonfüggvények
│       ├── ingress.yaml          # Közös Ingress (Vanilla Kubernetes)
│       ├── argocd/               # ArgoCD erőforrások
│       ├── grafana/              # Grafana
│       ├── jenkins/              # Jenkins
│       └── kafka/                # Kafka (StatefulSet + Service)
└── README.md                     # Dokumentáció
```

---

# 🚀 Telepítési útmutató (Vanilla Kubernetes)

Ha szabványos Kubernetes környezetben (pl. **Minikube**, **k3d**, **Docker Desktop**, **MicroK8s**) telepítesz, akkor a hálózati elérést a beépített `ingress.yaml` biztosítja.

```bash
# 1. Namespace létrehozása
kubectl create namespace devops

# 2. Helm sablonok ellenőrzése (Dry Run)
helm template devops-tools ./devops-tools --namespace devops

# 3. Telepítés
helm install devops-tools ./devops-tools --namespace devops

# 4. Frissítés
helm upgrade devops-tools ./devops-tools --namespace devops
```

---

# 🔴 OpenShift (CRC) specifikus beállítások

OpenShift (CodeReady Containers) környezetben a szolgáltatások publikálása nem Ingress segítségével történik, hanem a beépített **HAProxy Router (Route)** használatával.

## 1. Szolgáltatások publikálása (Route létrehozása)

Az alapértelmezett `ClusterIP` szolgáltatásokat publikálni kell.

```bash
oc expose service jenkins-service --name=jenkins --port=web -n devops
oc expose service grafana-service --name=grafana -n devops
oc expose service kafka-service --name=kafka -n devops
```

---

## 2. ArgoCD HTTPS / SSL probléma megoldása

Az ArgoCD HTTPS kapcsolatot vár. Ha sima HTTP Route készül, akkor az alábbi hiba jelenik meg:

> Application is not available

A megoldás egy **Edge TLS** Route létrehozása.

```bash
# Hibás Route törlése
oc delete route argocd -n devops

# Edge TLS Route létrehozása
oc create route edge argocd \
  --service=argocd-server-service \
  --port=8080 \
  -n devops
```

Sikeres létrehozás után az ArgoCD elérhető lesz például:

```
https://argocd-devops.apps-crc.testing
```

---

# 🛠️ Ismert korlátok és fejlesztési terv (Roadmap)

A platform jelenleg stabil **Proof-of-Concept** állapotban van.

A produkciós használathoz az alábbi fejlesztések szükségesek.

| Modul | Probléma | Tervezett megoldás |
|-------|----------|--------------------|
| **ArgoCD** | RBAC jogosultsági problémák a default Service Account használata miatt | Saját Service Account és dedikált RBAC szabályok kialakítása |
| **Kafka** | Lokális tárolás miatt pod újraindításkor adatvesztés történik | StatefulSet átalakítása PVC alapú perzisztens tárolásra |
| **Storage** | Jenkins és Grafana állapota elveszik pod újraindítás után | Persistent Volume (PV) és Persistent Volume Claim (PVC) használata |
| **Karbantarthatóság** | Egyedi YAML fájlok folyamatos karbantartást igényelnek | Umbrella Chart kialakítása hivatalos upstream Helm Chart dependency-k használatával |

---

# 🌿 Git Branch stratégia

A projekt az alábbi Git branching modellt használja.

| Branch | Leírás |
|---------|--------|
| **main** | Stabil, tesztelt kiadások |
| **develop** | Folyamatos integrációs ág |
| **feature/setup** | Az infrastruktúra és DevOps eszközök fejlesztése |

---

# 📦 Jelenleg támogatott komponensek

- Jenkins
- ArgoCD
- Grafana
- Kafka

---

# 🎯 Projekt célja

A projekt célja egy könnyen telepíthető, lokális DevOps platform biztosítása, amely alkalmas:

- CI/CD folyamatok kipróbálására
- Kubernetes és Helm gyakorlására
- GitOps megközelítés demonstrálására
- OpenShift (CRC) kompatibilis környezet biztosítására
- DevOps eszközök integrációjának bemutatására

---

 # To do

Hátralévő teendők

- Kafka se működik, nem indul el az alkalmazás
- Már megírt Helm Chartok használata hogy ne kelljen minden alkalommal újrakonfigurálni mindent ha pl új környezetre tlepülnék ki, vagy elveszik a volume 

Szépítgetések

- ArgoCD nem a Helm Chart-al jön létre működik
- Minden Service ClusterIP-t használ, csak a Grafana nem, ő NodePort-ot használ, amivel localhost:definiált port-on érhető el