###Weather App###

The user is expected to open up the app and find the current weather forecast for their current location. The weather forecast is shown on the main page with the current weather icon, temp, and city/state. The forecast is shown for the next 48 hours and is shown in a grid. The user may also change their location by providing a latitude and longitude for their new location by pressing the + in the upper right corner. The app will then go out and fetch a new weather forecast for that location. The Weather App also includes a favorites list that includes all of the entered locations. The user may click on one of the cells in the list to favorite the item and once its favorited it will become their primary forecast. The favorited forecast persists app death and will show if the app is killed. If the user has not selected a favorite the app will persist the current location and show that forecast.

The app uses the Open Weather Map endpoint for getting json data. The api takes a key that I have provided in this document and also directly sourced in the code. I know this is not best practice but I don't plan on putting the project on Github.

Api Key = {Add_Api_Key_Here}
