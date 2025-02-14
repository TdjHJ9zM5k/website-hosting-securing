/*********
 .jsw file
 *********

 Backend .jsw files contain functions that run on the server side but can be called from page code and frontend files.
 Use backend functions to keep code private and hidden from a user's browser. More info:

 https://support.wix.com/en/article/velo-web-modules-calling-backend-code-from-the-frontend

**********/
import {fetch} from 'wix-fetch';


/*********
 REFERENCES
 *********
 * 
 * Yr API Documentation https://api.met.no/weatherapi/locationforecast/2.0/documentation
 * Yr GitHub Weather icons and codes https://github.com/metno/weathericons/tree/main/weather
 * 
 */

export function getWeatherFromYr() {
    // API endpoint remains the same, unless changed by the API provider.
    const url = "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=56.03&lon=12.62";
    const iconUrl = "https://raw.githubusercontent.com/metno/weathericons/refs/heads/main/weather";
    const iconFormat = "png";
    // You can force a custom code by uncommenting the following line:
    const customCode = null; // e.g. "lightssleetshowersandthunder_polartwilight";

    // Define the custom User-Agent string to avoid a 403 error as described here:
    // https://api.met.no/doc/TermsOfService
    const userAgent = "user-agent";

    const headers = {
        "User-Agent": userAgent,
        "Accept": "application/json"
    };

    const options = {
        method: "GET",
        headers: headers
    };

    return fetch(url, options)
        .then(response => {
            if (response.ok) {
                return response.json();
            } else {
                // If the response is not OK, throw an error.
                throw new Error("Errore nella chiamata API " + response.statusText);
            }
        })
        .then(data => {
            // With the new API response, we get an array of timeseries objects.
            // We use the first one to extract current weather details.
            const firstTimeseries = data.properties.timeseries[0];
            const weatherDetails = firstTimeseries.data;

            // Extract temperature from the "instant" data.
            const temperature = weatherDetails.instant.details.air_temperature;

            // Extract the forecast from the "next_12_hours" data if available.
            // (If for some reason it is missing, we default to an empty string.)
            let forecast = weatherDetails.next_12_hours && weatherDetails.next_12_hours.summary
                ? weatherDetails.next_12_hours.summary.symbol_code
                : "";

            // Optionally override the forecast with a custom code if provided.
            if (customCode) {
                forecast = customCode;
            }

            // Debug log to show the request time, temperature, and forecast.
            const requestDate = new Date().toISOString();
            console.debug(`Request Date: ${requestDate}, Temperature: ${temperature.toFixed(1)}°C, Forecast: ${forecast}`);

            // Return the desired weather object.
            return {
                avgTemp: temperature.toFixed(1),
                mostCommonWeather: forecast.split('_')[0],
                weatherIcon: `${iconUrl}/${iconFormat}/${forecast}.${iconFormat}`
            };
        })
        .catch(error => {
            console.error("Errore nella funzione getWeatherSummary:", error);
            throw new Error("Impossibile ottenere il meteo - URL: " + url + "   error: " + error);
        });
}


export function getForecastThreeDays() {
    const url = "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=56.03&lon=12.62";
    const iconBaseUrl = "https://raw.githubusercontent.com/metno/weathericons/refs/heads/main/weather";
    const iconFormat = "png";
    const userAgent = "user-agent";

    const headers = {
        "User-Agent": userAgent,
        "Accept": "application/json"
    };

    const options = {
        method: "GET",
        headers: headers
    };

    // Helper function to format a Date object as dd/mm
    function formatDate(dateObj) {
        const day = String(dateObj.getDate()).padStart(2, "0");
        // Note: getMonth() returns 0-indexed months (0 = January). Add 1.
        const month = String(dateObj.getMonth() + 1).padStart(2, "0");
        return `${day}/${month}`;
    }

    return fetch(url, options)
        .then(response => {
            if (!response.ok) {
                throw new Error("API request failed: " + response.statusText);
            }
            return response.json();
        })
        .then(data => {
            const timeseries = data.properties.timeseries;

            // Today's forecast: use the first available entry for today.
            const today = new Date();
            const todayDateStr = today.toISOString().split("T")[0];
            const todayEntries = timeseries.filter(entry => entry.time.startsWith(todayDateStr));

            // Create a target time string for today at 06:00:00Z and log it.
            console.log(`Processing forecast for target time: ${todayDateStr}`);
            
            if (todayEntries.length === 0) {
                throw new Error("No weather data available for today.");
            }
            const firstToday = todayEntries[0];
            const tempToday = firstToday.data.instant.details.air_temperature.toFixed(1);
            const forecastTodayRaw = firstToday.data.next_12_hours?.summary.symbol_code || "";
            const todayForecast = {
                avgTemp: tempToday,
                mostCommonWeather: forecastTodayRaw.split('_')[0],
                weatherIcon: `${iconBaseUrl}/${iconFormat}/${forecastTodayRaw}.${iconFormat}`
            };

            // Helper: for a given day offset (1 for tomorrow, 2 for day after), find the timeseries entry at 06:00:00Z.
            function getFixedTimeForecast(dayOffset) {
                const dateObj = new Date();
                dateObj.setDate(dateObj.getDate() + dayOffset);
                const dateStr = dateObj.toISOString().split("T")[0]; // "YYYY-MM-DD"
                const targetTime = `${dateStr}T06:00:00Z`;
                console.log(`Processing forecast for target time: ${dateStr}`);
                const entry = timeseries.find(e => e.time === targetTime);
                if (!entry) {
                    throw new Error(`No weather data available for ${targetTime}`);
                }
                const temp = entry.data.instant.details.air_temperature.toFixed(1);
                const symbolCode = entry.data.next_12_hours?.summary.symbol_code || "unknown";
                return {
                    avgTemp: temp,
                    mostCommonWeather: symbolCode,
                    weatherIcon: `${iconBaseUrl}/${iconFormat}/${symbolCode}.${iconFormat}`,
                    date: formatDate(dateObj)
                };
            }

            const tomorrowForecast = getFixedTimeForecast(1);
            const dayAfterForecast = getFixedTimeForecast(2);
            var result = {
                avgTemp_today: todayForecast.avgTemp,
                mostCommonWeather_today: todayForecast.mostCommonWeather,
                weatherIcon_today: todayForecast.weatherIcon,
                date_today: formatDate(today),

                avgTemp_today_plusOne: tomorrowForecast.avgTemp,
                mostCommonWeather_today_plusOne: tomorrowForecast.mostCommonWeather,
                weatherIcon_today_plusOne: tomorrowForecast.weatherIcon,
                date_today_plusOne: tomorrowForecast.date,

                avgTemp_today_plusTwo: dayAfterForecast.avgTemp,
                mostCommonWeather_today_plusTwo: dayAfterForecast.mostCommonWeather,
                weatherIcon_today_plusTwo: dayAfterForecast.weatherIcon,
                date_today_plusTwo: dayAfterForecast.date
            };

            return result;
        })
        .catch(error => {
            console.error("Error fetching 3-day forecast:", error);
            throw new Error("Unable to retrieve the 3-day weather forecast.");
        });
}
