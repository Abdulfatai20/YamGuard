=============
YamGuard – Intelligent Yam Storage Advisor
=============

YamGuard is a smart mobile-based assistant designed to help yam farmers in Southwestern Nigeria reduce post-harvest losses. The app offers personalized storage recommendations based on weather forecasts, yam condition, and storage duration. It integrates machine learning, real-time data, and intuitive design to support informed storage decisions.

=============  
Features  
=============

1. **User Authentication**  
   Secure user registration and login with Firebase Authentication.

2. **Weather Forecasting**  
   Uses OpenWeatherMap API to provide: 🔗 https://openweathermap.org
   - Real-time weather data and storage advice based on today's forecast conditions 
   - 7-day forecast for key climate indicators

3. **Forecast-Based Storage Recommendation**  
   Suggests best storage methods (barn, pit, ash/sawdust, crate) based on:
   - Yam type and condition (whole/cut)
   - Forecast duration (14/30/60/90 days)
   - Trained Prophet models for average temperature, humidity, rainfall, and max temperature

4. **Educational Yam Info Module**  
   Offers brief content on yam types, traditional storage techniques, and best practices.

5. **Alerts & Notifications** 
   Sends intelligent warnings:
   - Dry Season and Wet Season alerts 
   - Extreme Weather notifications sent two days in advance

=============  
Tech Stack  
=============

Frontend: Flutter  
Backend: FastAPI (deployed on Render)  
Forecasting Model: Prophet (Facebook open-source)  
Weather API: OpenWeatherMap  
Authentication: Firebase 🔗 https://firebase.google.com
Cloud Database: Firestore (Firebase)  
Deployment (Frontend): Flutter APK  
Deployment (Backend): Render
The backend is fully developed in Python, leveraging the FastAPI framework for building high-performance APIs.


=============  
Backend Info
=============
FastAPI Backend (for Recommendations)

Recommendation Endpoint (POST)
 **How to Test the FastAPI Backend via Swagger UI which can be used to test the backend in the browser

🔗 Swagger UI URL: https://yamguard.onrender.com/docs

This link opens a Swagger interface where the API endpoints can be tested without writing any code.

Steps to Test the Storage Recommendation Endpoint
Open this link in a browser:
👉 https://yamguard.onrender.com/docs

Scroll to the POST /recommendation/ section.
Click to expand it.

Click “Try it out”.

Enter sample input like below:

{
  "yam_type": "white yam",
  "condition": whole
  "duration": 30_day
}
(Replace values as needed: "whole" or "cut" for condition, duration can be 14_day, 30_day, 60_day, or 90_day, white yam, yellow yam, water yam or bitter for the yam_type)

Click “Execute”.

You will get a JSON response with:

-Recommended storage method

-Forecast Summary for the selected duration

-Indoor/outdoor advice

-Wet or Dry Season Alert 

-Reasons Why other storage methods were not selected


Yam Types Endpoint (GET)
Returns available yam varieties and related metadata. Can be tested directly in the browser.
🔗 https://yamguard.onrender.com/yam-types

API Hosting Dashboard (Render)
The backend is hosted and live here: 🔗 https://dashboard.render.com/web/srv-d1m8pf2dbo4c73f1sk20

=============  
Dataset 
=============

Weather Dataset (used to train Prophet models):  
📊 [Google Sheet](https://docs.google.com/spreadsheets/d/1RFmep1gG5UVLADiXheArLUYHs82hp4PNVxPmovsznuo/edit)  
(Source: Meteostat, Data from 2023 to June 2025) 🔗 https://dev.meteostat.net
 

=============
Prequisite 
=============
Flutter SDK ≥ 3.0 needs to be installed  🔗 https://docs.flutter.dev/get-started/install

Git for cloning the project 🔗 https://git-scm.com/

=============
Installation
=============
1- Clone the repository - git https://github.com/Abdulfatai20/YamGuard.git
2- Install dependencies - flutter pub get
3- Run the app - flutter run
✅ No Python installation required
The backend with the trained Prophet model is already deployed via Render.

=============
RiceSence Deployment APK
=============
The app has already been built and included in the /build folder.
File: YamGuard_v1.apk

Copy it to any Android phone and install directly to begin testing.

=============
Github repository
=============
https://github.com/Abdulfatai20/YamGuard/tree/main

Mahmood Abdulfatai: Full Stack developer, UI/UX Designer, Data Preprocessing.


 