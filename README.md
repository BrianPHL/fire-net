# FireNet
A decentralized IoT-based fire, gas, and smoke detection network with centralized mobile monitoring and alerting

## Project Overview

**FireNet** is a decentralized Internet of Things (IoT) fire detection system designed to support early identification of fire-related hazards in residential and small commercial environments. The system consists of multiple low-cost sensor nodes that locally monitor fire, gas, and smoke indicators and transmit evaluated data to a centralized platform. A mobile application provides real-time monitoring and alert notifications to users.

FireNet is developed as a **proof-of-concept academic project**, focusing on system architecture, data aggregation, and IoT–mobile application integration.

## Project Objectives

- Design a decentralized IoT sensor network for fire, gas, and smoke detection  
- Implement local threshold-based evaluation at sensor nodes  
- Aggregate and analyze sensor data centrally using rule-based logic  
- Provide real-time monitoring and alerts through a mobile application  
- Evaluate system feasibility through a controlled, small-scale deployment  

## System Architecture

**FireNet follows a three-layer architecture:**

1. **Decentralized Sensor Nodes**
   - Fire, gas, and smoke sensors
   - Local preprocessing and threshold checks
   - Wireless data transmission

2. **Centralized Backend**
   - Data aggregation
   - Hazard severity evaluation
   - Alert generation

3. **Mobile Monitoring Application**
   - Real-time visualization
   - Push notifications
   - Historical alert records

## Technologies Used

### Mobile Application
- **Flutter** – Cross-platform UI framework  
- **Dart** – Application logic  

### IoT & Embedded Systems
- **ESP32 / ESP8266** microcontrollers  
- **Smoke & Gas Sensors** (e.g., MQ series)  
- **Temperature Sensors** (e.g., DHT22 / DS18B20)  

### Cloud & Backend
- **Firebase**
  - Firestore / Realtime Database
  - Cloud Messaging (notifications)
  - Authentication (optional)
- **Wi-Fi Communication**

## Features
- Multi-node decentralized fire, gas, and smoke detection  
- Local threshold-based hazard evaluation  
- Centralized data aggregation  
- Real-time mobile monitoring dashboard  
- Push notifications for alerts  
- Alert severity classification (e.g., warning, critical)  
- Historical alert and system logs  
- Modular and scalable system design

## Installation Instructions

### Prerequisites
- Flutter SDK installed  
- Android Studio / VS Code  
- Compatible Android or iOS device/emulator  

### Clone the Repository
```bash
git clone https://github.com/your-username/firenet.git
cd firenet
```

### Install Dependencies
```bash
flutter pub get
```

# Run the Application
```bash
flutter run
```
## Project Scope & Limitations
- Small-scale, indoor deployment only
- Rule-based hazard detection (no machine learning)
- Proof-of-concept implementation
- Not intended for industrial, certified, or life-critical deployment

## Contributors
- **Bri** ([BrianPHL](https://github.com/BrianPHL))
- **Railey** ([raileyyyy](https://github.com/raileyyyy))
- **Aidan** ([AiD4HN](https://github.com/AiD4HN))
- **Kyle**
- **Alaine**

## Target Timeline
April 15 - 19, 2026

## Contact
For questions or collaboration inquiries, please contact the project team.
