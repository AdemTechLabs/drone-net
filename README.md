# 🛰️ DRONE-NET — Système de Commandement Tactique Blockchain

> Plateforme de gestion de flotte de drones sécurisée par la blockchain Ethereum.  
> Interface de commandement militaire avec radar 3D, caméra FPV immersive et audit immuable on-chain.

![Version](https://img.shields.io/badge/version-3.0-cyan)
![Solidity](https://img.shields.io/badge/Solidity-0.8.x-blue)
![Three.js](https://img.shields.io/badge/Three.js-r128-green)
![Ethereum](https://img.shields.io/badge/Ethereum-Testnet-purple)

---

## 🎯 Concept

Dans un système classique (base de données SQL), un administrateur malveillant peut effacer les traces d'un incident ou modifier l'identité d'un pilote. **DRONE-NET résout ce problème** en enregistrant chaque action sur la blockchain Ethereum :

- **Immuabilité** : aucun ordre ne peut être falsifié après coup
- **Souveraineté numérique** : identité gérée par cryptographie (MetaMask)
- **Transparence totale** : audit mathématique de chaque mouvement

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│              INTERFACE TACTIQUE                  │
│         HTML / CSS / JavaScript                  │
│   Radar 3D · FPV World · Mission Control         │
└──────────────────┬──────────────────────────────┘
                   │ ethers.js
┌──────────────────▼──────────────────────────────┐
│            SMART CONTRACT                        │
│         DroneFleet_v2.sol (Solidity)             │
│   Rôles · Positions · Formations · Essaim        │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│           BLOCKCHAIN ETHEREUM                    │
│              (Testnet Geth)                      │
│         Immuable · Décentralisé · Auditable      │
└─────────────────────────────────────────────────┘
```

---

## ✨ Fonctionnalités

### 🎮 Pilotage Temps Réel
- Contrôle clavier **ZQSD / Flèches** pour déplacer les drones
- **A/E** pour l'altitude · **TAB** pour changer de drone
- **ENTER** pour valider la position sur la blockchain
- Mouvement visuel instantané, transaction on-chain asynchrone

### 📡 Radar 3D (Three.js)
- Scène 3D avec grille néon, anneaux concentriques et sweep rotatif
- Drones représentés par des octaèdres avec code couleur (vert/orange/rouge/jaune)
- **Clic sur un drone** pour le sélectionner directement dans la scène
- Trajectoires tracées en temps réel (trail system)
- HUD overlay avec position, altitude, batterie

### 🌍 Caméra FPV Immersive (Three.js)
- Monde 3D procédural : terrain avec relief, bâtiments, arbres, étoiles
- Caméra cockpit attachée au drone sélectionné avec inertie
- Horizon artificiel, boussole rotative, altimètre
- Réticule de verrouillage animé (TARGET_LOCKED)

### 🪖 Commandes Tactiques
| Commande | Description |
|----------|-------------|
| **Formation V** | Chef en tête, flancs gauche/droit |
| **Formation Ligne** | Tous alignés horizontalement |
| **Formation Cercle** | Protection périmétrique |
| **Mode Essaim** | Tous les drones suivent le chef |
| **Waypoint** | Envoyer vers coordonnées X, Y, Altitude |
| **Interception** | Verrouiller et intercepter une cible |

### 🔗 Blockchain
- Flux de transactions en temps réel
- Journal d'audit immuable
- Stats live (OPS TX, alertes, état de la flotte)

---

## 👥 Rôles Opérateurs

| Rôle | Emoji | Responsabilités |
|------|-------|-----------------|
| **Commandant** | ⭐ | Déploiement, maintenance, archivage |
| **Pilote Tactique** | 🎮 | Vol, scan, waypoints, formations |
| **Technicien Sol** | 🔧 | Maintenance uniquement |

---

## 🚀 Installation & Démo

### Prérequis
- [MetaMask](https://metamask.io/) installé dans Chrome
- [Remix IDE](https://remix.ethereum.org/) pour déployer le contrat
- Un serveur local (Live Server VSCode, `python -m http.server`, etc.)

### Déploiement

**1. Déployer le Smart Contract**
```
1. Ouvrir Remix IDE → remix.ethereum.org
2. Créer DroneFleet_v2.sol et coller le code
3. Compiler (Solidity 0.8.x)
4. Deploy & Run → Injected Provider MetaMask
5. Copier l'adresse du contrat déployé
```

**2. Configurer l'interface**
```javascript
// Dans index.html, ligne ~555
const CONTRACT_ADDRESS = "0xTON_ADRESSE_ICI";
```

**3. Lancer**
```bash
# Python
python -m http.server 8080

# Node
npx serve .
```
Ouvrir `http://localhost:8080`

### Workflow de démo
```
1. Connecter MetaMask (compte Admin)
2. Déployer des unités → LANCER UNITÉ
3. Changer de compte → enregistrer un Pilote
4. Sélectionner un drone → piloter avec ZQSD
5. ENTER → valider la position on-chain
6. Tester formations, waypoints, essaim
7. Consulter le journal d'audit
```

---

## 🛠️ Stack Technique

| Technologie | Usage |
|-------------|-------|
| **Solidity 0.8** | Smart Contract (logique métier on-chain) |
| **Ethereum / Web3** | Blockchain de traçabilité |
| **ethers.js** | Connexion MetaMask ↔ contrat |
| **Three.js r128** | Radar 3D + Monde FPV immersif |
| **HTML/CSS/JS** | Interface tactique (zero framework) |

---

## 📁 Structure

```
drone-net/
├── index.html          # Interface complète (HTML + CSS + JS)
├── ether.js            # Bibliothèque ethers.js
├── DroneFleet_v2.sol   # Smart Contract Solidity
└── README.md           # Documentation
```

---

## 🎖️ Cas d'usage Industrie

Ce projet démontre des compétences directement applicables chez **Thales, Dassault Aviation, Palantir** :

- **Gestion d'actifs critiques** avec traçabilité totale
- **Simulation IoT** (énergie, température, altitude, télémétrie)
- **Cybersécurité** via cryptographie asymétrique
- **Visualisation 3D** pour la situation awareness
- **Architecture distribuée** et résiliente

---

## ⚠️ Notes Techniques

- Le projet tourne sur un testnet Ethereum local (Geth 1337)
- Les positions on-chain sont des `int256` — conversion sécurisée via `.toString()` pour éviter les overflows JavaScript
- Deux scènes Three.js indépendantes (radar + FPV) avec gestion des contextes WebGL
- Mouvement ZQSD = visuel instantané · ENTER = transaction blockchain (séparation UX/on-chain)

---

*Projet réalisé dans le cadre d'une démonstration des capacités Blockchain × IoT × Visualisation 3D*
