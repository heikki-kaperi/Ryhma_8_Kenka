<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm5.aspx.cs" Inherits="tyhja_9.WebForm5" %>

<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
        <meta charset="UTF-8">
	    <title>Ryhmä 8 Kenkä</title>	
	    <link rel="stylesheet" href="style.css">
</head>
<body>
      <section class="section hero">
		<div class="container">
			<div class="hero-content">
            <p class="yläteksti"> 24 tunnin aikana saapuvat laivat</p>
				<p class="hero-text"> 
				<br>
				<table style="width:70%; padding-left: 30%" class="center">
				
					<tr>
						<td>
						<p class="satamateksti"> Satama </p>
						</td>

<!--	Tästä kohtaan lomake kyselyn täyttäminen alkaa	-->

						<td>
    <form id="form1" runat="server">
        <div>
            
            
            <%
// Initialize counter in session if it doesn't exist or if it's a fresh load
if (!IsPostBack && Session["Counter"] == null)
{
    Session["Counter"] = 0;
}

// Initialize selected port if it doesn't exist
if (Session["SelectedPort"] == null)
{
    Session["SelectedPort"] = ""; // Default empty value
}

// Initialize selected ship if it doesn't exist
if (Session["SelectedShip"] == null)
{
    Session["SelectedShip"] = ""; // Default empty value
}

// Initialize ship information if it doesn't exist
if (Session["ShipNationality"] == null)
{
    Session["ShipNationality"] = ""; // Default empty value
}

if (Session["ArrivalTime"] == null)
{
    Session["ArrivalTime"] = ""; // Default empty value
}

if (Session["DepartureTime"] == null)
{
    Session["DepartureTime"] = ""; // Default empty value
}

if (Session["PortArea"] == null)
{
    Session["PortArea"] = ""; // Default empty value
}

// Add vessel type session variable
if (Session["VesselType"] == null)
{
    Session["VesselType"] = ""; // Default empty value
}

// Add MMSI session variable
if (Session["MMSI"] == null)
{
    Session["MMSI"] = ""; // Default empty value
}

// Add GPS Coordinates session variable
if (Session["GPSCoordinates"] == null)
{
    Session["GPSCoordinates"] = ""; // Default empty value
}

// Flag to track if refresh button was pressed
bool refreshButtonPressed = false;

// Handle refresh button click
if (IsPostBack && Request.Form["btnRefresh"] != null)
{
    refreshButtonPressed = true;
    
    // Save the selected port code to session
    Session["SelectedPort"] = Request.Form["ddlOptions"];
    
    // Save the selected ship to session
    Session["SelectedShip"] = Request.Form["ddlShips"];
    
    // Increment counter
    int i = (int)Session["Counter"];
    i = (i >= 2) ? 0 : i + 1;
    Session["Counter"] = i;
}

// Get the selected port and ship as strings
string selectedPort = Session["SelectedPort"].ToString();
string selectedShip = Session["SelectedShip"].ToString();
string shipNationality = Session["ShipNationality"].ToString();
string arrivalTime = Session["ArrivalTime"].ToString();
string departureTime = Session["DepartureTime"].ToString();
string portArea = Session["PortArea"].ToString();
string vesselType = Session["VesselType"].ToString();
string mmsi = Session["MMSI"].ToString();
string gpsCoordinates = Session["GPSCoordinates"].ToString();

// Dictionary to store ship names and their details
Dictionary<string, Dictionary<string, string>> shipDetails = new Dictionary<string, Dictionary<string, string>>();

// Only fetch ship data if a port is selected
if (!string.IsNullOrEmpty(selectedPort))
{
    try
    {
        StringWriter writer = new StringWriter();
        HttpWebRequest myRequest = 
            (HttpWebRequest)WebRequest.Create(@"https://meri.digitraffic.fi/api/port-call/v1/port-calls");
        myRequest.AutomaticDecompression = DecompressionMethods.GZip;
        WebResponse response = myRequest.GetResponse();
        Stream dataStream = response.GetResponseStream();
        StreamReader reader = new StreamReader(dataStream);
        string resp = reader.ReadToEnd();
        
        // Use the selected port code from dropdown
        string satamakoodi = selectedPort;
        
        // Get current time for filtering ships
        DateTime currentTime = DateTime.Now;
        DateTime oneDayAgo = currentTime.AddDays(-1);
        DateTime oneDayLater = currentTime.AddDays(1);
        
        int rivi = resp.IndexOf("\"portToVisit\" : \"" + satamakoodi);
        while (rivi >= 0)
        {
            int lahtopaikka = resp.IndexOf("\"prevPort", rivi);
            string lahtosatama = resp.Substring(lahtopaikka + 14, 2);
            
            // Create a dictionary for this ship's details
            Dictionary<string, string> shipInfo = new Dictionary<string, string>();
            bool shipInTimeWindow = false;
            
            // Find the vessel name
            int laivanpaikka = resp.IndexOf("\"vesselName\" :", rivi);
            if (laivanpaikka >= 0)
            {
                laivanpaikka += 16; // Position after "vesselName" : "
                int laivanLoppu = resp.IndexOf(",", laivanpaikka);
                string laivanNimi = resp.Substring(laivanpaikka, laivanLoppu - 1 - laivanpaikka);
                
                // Find and extract MMSI number - NEW CODE HERE
                shipInfo["mmsi"] = ""; // Default empty value
                int mmsiPaikka = resp.IndexOf("\"mmsi\" :", rivi);
                if (mmsiPaikka >= 0)
                {
                    mmsiPaikka += 9; // Position after "mmsi" : 
                    // Skip spaces
                    while (mmsiPaikka < resp.Length && char.IsWhiteSpace(resp[mmsiPaikka]))
                        mmsiPaikka++;
                    
                    // Find the end of the mmsi value (usually a comma)
                    int mmsiLoppu = resp.IndexOf(",", mmsiPaikka);
                    if (mmsiLoppu > mmsiPaikka)
                    {
                        string mmsiValue = resp.Substring(mmsiPaikka, mmsiLoppu - mmsiPaikka);
                        shipInfo["mmsi"] = mmsiValue.Trim();
                    }
                }
                
                // Find and extract vessel type code
                shipInfo["vesselType"] = "Rahtialus"; // Default value
                int vesselTypeCodePaikka = resp.IndexOf("\"vesselTypeCode\" :", rivi);
                if (vesselTypeCodePaikka >= 0)
                {
                    vesselTypeCodePaikka += 18; // Position after "vesselTypeCode" : 
                    // Skip spaces
                    while (vesselTypeCodePaikka < resp.Length && char.IsWhiteSpace(resp[vesselTypeCodePaikka]))
                        vesselTypeCodePaikka++;
                    
                    int vesselTypeCodeLoppu = resp.IndexOf(",", vesselTypeCodePaikka);
                    if (vesselTypeCodeLoppu > vesselTypeCodePaikka)
                    {
                        string vesselTypeCodeStr = resp.Substring(vesselTypeCodePaikka, vesselTypeCodeLoppu - vesselTypeCodePaikka);
                        // Convert to integer and map to vessel type
                        int vesselTypeCode;
                        if (int.TryParse(vesselTypeCodeStr, out vesselTypeCode))
                        {
                            // Map code to vessel type
                            if (vesselTypeCode == 20)
                                shipInfo["vesselType"] = "Patosiipialus (WIG)";
                            else if (vesselTypeCode == 40)
                                shipInfo["vesselType"] = "Pika-alus (HSC)";
                            else if (vesselTypeCode == 50)
                                shipInfo["vesselType"] = "Luotsi";
                            else if (vesselTypeCode == 70)
                                shipInfo["vesselType"] = "Rahtialus";
                            else if (vesselTypeCode >= 80 && vesselTypeCode <= 83)
                                shipInfo["vesselType"] = "Tankkeri";
                            else if (vesselTypeCode >= 90 && vesselTypeCode <= 95)
                                shipInfo["vesselType"] = "Muu alus";
                            else
                                shipInfo["vesselType"] = "Tuntematon alus";
                        }
                    }
                }
                
                // Find and extract nationality
                shipInfo["nationality"] = ""; // Default empty value
                int nationalityPaikka = resp.IndexOf("\"nationality\" :", rivi);
                if (nationalityPaikka >= 0)
                {
                    nationalityPaikka += 17; // Position after "nationality" : "
                    int nationalityLoppu = resp.IndexOf("\"", nationalityPaikka);
                    string nationality = resp.Substring(nationalityPaikka, nationalityLoppu - nationalityPaikka);
                    shipInfo["nationality"] = nationality;
                }
                
                // Extract arrival time (ata)
                shipInfo["arrivalTime"] = "";  // Default empty value
                int ataIndex = resp.IndexOf("\"ata\" :", rivi);
                if (ataIndex >= 0)
                {
                    // Check if value is null
                    int valueStartIdx = ataIndex + 7;
                    // Skip spaces
                    while (valueStartIdx < resp.Length && char.IsWhiteSpace(resp[valueStartIdx]))
                        valueStartIdx++;
                    
                    if (resp.Substring(valueStartIdx, 4) != "null")
                    {
                        // Value is a string, not null
                        int stringStartIdx = resp.IndexOf("\"", valueStartIdx) + 1;
                        int stringEndIdx = resp.IndexOf("\"", stringStartIdx);
                        if (stringStartIdx > 0 && stringEndIdx > stringStartIdx)
                        {
                            string fullAtaValue = resp.Substring(stringStartIdx, stringEndIdx - stringStartIdx);
                            // Extract date and time portion (2025-04-08T20:59) from the full timestamp
                            if (fullAtaValue.Length >= 16)
                            {
                                string ataTimeValue = fullAtaValue.Substring(0, 16);
                                shipInfo["arrivalTime"] = ataTimeValue;
                                
                                // Check if arrival time is within the last 24 hours
                                DateTime arrivalDateTime;
                                if (DateTime.TryParse(ataTimeValue, out arrivalDateTime))
                                {
                                    if (arrivalDateTime >= oneDayAgo && arrivalDateTime <= currentTime)
                                    {
                                        shipInTimeWindow = true;
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        // Try to look for eta instead if ata is null
                        int etaIndex = resp.IndexOf("\"eta\" :", rivi);
                        if (etaIndex >= 0)
                        {
                            int etaValueStartIdx = etaIndex + 7;
                            // Skip spaces
                            while (etaValueStartIdx < resp.Length && char.IsWhiteSpace(resp[etaValueStartIdx]))
                                etaValueStartIdx++;
                            
                            if (resp.Substring(etaValueStartIdx, 4) != "null")
                            {
                                int etaStringStartIdx = resp.IndexOf("\"", etaValueStartIdx) + 1;
                                int etaStringEndIdx = resp.IndexOf("\"", etaStringStartIdx);
                                if (etaStringStartIdx > 0 && etaStringEndIdx > etaStringStartIdx)
                                {
                                    string fullEtaValue = resp.Substring(etaStringStartIdx, etaStringEndIdx - etaStringStartIdx);
                                    if (fullEtaValue.Length >= 16)
                                    {
                                        string etaTimeValue = fullEtaValue.Substring(0, 16);
                                        shipInfo["arrivalTime"] = etaTimeValue;
                                        
                                        // Check if estimated arrival is within the next 24 hours
                                        DateTime estimatedArrivalDateTime;
                                        if (DateTime.TryParse(etaTimeValue, out estimatedArrivalDateTime))
                                        {
                                            if (estimatedArrivalDateTime >= currentTime && estimatedArrivalDateTime <= oneDayLater)
                                            {
                                                shipInTimeWindow = true;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Extract departure time (etd)
                shipInfo["departureTime"] = "";  // Default empty value
                int etdIndex = resp.IndexOf("\"etd\" :", rivi);
                if (etdIndex >= 0)
                {
                    // Check if value is null
                    int valueStartIdx = etdIndex + 7;
                    // Skip spaces
                    while (valueStartIdx < resp.Length && char.IsWhiteSpace(resp[valueStartIdx]))
                        valueStartIdx++;
                    
                    if (resp.Substring(valueStartIdx, 4) != "null")
                    {
                        // Value is a string, not null
                        int stringStartIdx = resp.IndexOf("\"", valueStartIdx) + 1;
                        int stringEndIdx = resp.IndexOf("\"", stringStartIdx);
                        if (stringStartIdx > 0 && stringEndIdx > stringStartIdx)
                        {
                            string fullEtdValue = resp.Substring(stringStartIdx, stringEndIdx - stringStartIdx);
                            // Extract date and time portion (2025-04-09T17:00) from the full timestamp
                            if (fullEtdValue.Length >= 16)
                            {
                                shipInfo["departureTime"] = fullEtdValue.Substring(0, 16);
                            }
                        }
                    }
                }
                
                // Extract port area name
                shipInfo["portArea"] = "";  // Default empty value
                int portAreaIndex = resp.IndexOf("\"portAreaName\" :", rivi);
                if (portAreaIndex >= 0)
                {
                    // Check if value is null
                    int valueStartIdx = portAreaIndex + 16;
                    // Skip spaces
                    while (valueStartIdx < resp.Length && char.IsWhiteSpace(resp[valueStartIdx]))
                        valueStartIdx++;
                    
                    if (resp.Substring(valueStartIdx, 4) != "null")
                    {
                        // Value is a string, not null
                        int stringStartIdx = resp.IndexOf("\"", valueStartIdx) + 1;
                        int stringEndIdx = resp.IndexOf("\"", stringStartIdx);
                        if (stringStartIdx > 0 && stringEndIdx > stringStartIdx)
                        {
                            shipInfo["portArea"] = resp.Substring(stringStartIdx, stringEndIdx - stringStartIdx);
                        }
                    }
                    else
                    {
                        // If portAreaName is null, try to get portName instead
                        int portNameIndex = resp.IndexOf("\"portName\" :", rivi);
                        if (portNameIndex >= 0)
                        {
                            int portNameValueStartIdx = portNameIndex + 12;
                            // Skip spaces
                            while (portNameValueStartIdx < resp.Length && char.IsWhiteSpace(resp[portNameValueStartIdx]))
                                portNameValueStartIdx++;
                            
                            if (resp.Substring(portNameValueStartIdx, 4) != "null")
                            {
                                int portNameStringStartIdx = resp.IndexOf("\"", portNameValueStartIdx) + 1;
                                int portNameStringEndIdx = resp.IndexOf("\"", portNameStringStartIdx);
                                if (portNameStringStartIdx > 0 && portNameStringEndIdx > portNameStringStartIdx)
                                {
                                    shipInfo["portArea"] = resp.Substring(portNameStringStartIdx, portNameStringEndIdx - portNameStringStartIdx);
                                }
                            }
                        }
                    }
                }
                
                // Only store ships that are within the 24-hour window
                if (shipInTimeWindow)
                {
                    // Store all ship details
                    shipDetails[laivanNimi] = shipInfo;
                }
            }
            
            rivi = resp.IndexOf("\"portToVisit\" : \"" + satamakoodi, rivi + 1);
        }
        
        // Update the ship details if the ship is selected and the refresh button was pressed
        if (!string.IsNullOrEmpty(selectedShip) && shipDetails.ContainsKey(selectedShip) && refreshButtonPressed)
        {
            Dictionary<string, string> selectedShipDetails = shipDetails[selectedShip];
            
            Session["ShipNationality"] = selectedShipDetails.ContainsKey("nationality") && !string.IsNullOrEmpty(selectedShipDetails["nationality"]) ? 
                selectedShipDetails["nationality"] : "Ei tietoa";
            shipNationality = Session["ShipNationality"].ToString();
            
            Session["ArrivalTime"] = selectedShipDetails.ContainsKey("arrivalTime") && !string.IsNullOrEmpty(selectedShipDetails["arrivalTime"]) ? 
                selectedShipDetails["arrivalTime"] : "Ei tietoa";
            arrivalTime = Session["ArrivalTime"].ToString();
            
            Session["DepartureTime"] = selectedShipDetails.ContainsKey("departureTime") && !string.IsNullOrEmpty(selectedShipDetails["departureTime"]) ? 
                selectedShipDetails["departureTime"] : "Ei tietoa";
            departureTime = Session["DepartureTime"].ToString();
            
            Session["PortArea"] = selectedShipDetails.ContainsKey("portArea") && !string.IsNullOrEmpty(selectedShipDetails["portArea"]) ? 
                selectedShipDetails["portArea"] : "Ei tietoa";
            portArea = Session["PortArea"].ToString();
            
            // Update vessel type
            Session["VesselType"] = selectedShipDetails.ContainsKey("vesselType") && !string.IsNullOrEmpty(selectedShipDetails["vesselType"]) ? 
                selectedShipDetails["vesselType"] : "Rahtialus";
            vesselType = Session["VesselType"].ToString();
            
            // Update MMSI number - NEW CODE HERE
            Session["MMSI"] = selectedShipDetails.ContainsKey("mmsi") && !string.IsNullOrEmpty(selectedShipDetails["mmsi"]) ? 
                selectedShipDetails["mmsi"] : "Ei tietoa";
            mmsi = Session["MMSI"].ToString();

            // Check if MMSI is 0 before attempting to fetch GPS coordinates
            if (mmsi == "0")
            {
                // Set GPS coordinates to "Ei löytynyt" if MMSI is 0
                Session["GPSCoordinates"] = "Ei löytynyt";
                gpsCoordinates = "Ei löytynyt";
            }
            else if (!string.IsNullOrEmpty(mmsi) && mmsi != "Ei tietoa")
            {
                // Existing code to fetch GPS coordinates
                try
                {
                    // The rest of your API call code...
                }
                catch (Exception ex)
                {
                    // ...
                }
            }
            else
            {
                Session["GPSCoordinates"] = "Ei saatavilla";
                gpsCoordinates = "Ei saatavilla";
            }
            
            // Now fetch GPS coordinates using the MMSI number
            if (!string.IsNullOrEmpty(mmsi) && mmsi != "Ei tietoa")
            {
                try
                {
                    // Make a request to the AIS locations API
                    HttpWebRequest aisRequest = 
                        (HttpWebRequest)WebRequest.Create(@"https://meri.digitraffic.fi/api/ais/v1/locations");
                    aisRequest.AutomaticDecompression = DecompressionMethods.GZip;
                    WebResponse aisResponse = aisRequest.GetResponse();
                    Stream aisDataStream = aisResponse.GetResponseStream();
                    StreamReader aisReader = new StreamReader(aisDataStream);
                    string aisResp = aisReader.ReadToEnd();
                    
                    // Find the MMSI number in the AIS data
                    string mmsiSearch = "\"mmsi\" : " + mmsi;
                    int mmsiIndex = aisResp.IndexOf(mmsiSearch);
                    
                    if (mmsiIndex >= 0)
                    {
                        // Find the coordinates 
                        int coordsIndex = aisResp.IndexOf("\"coordinates\" : [", mmsiIndex);
                        if (coordsIndex >= 0)
                        {
                            coordsIndex += 16; // Position after "coordinates" : [
                            // Find the end of the coordinates array
                            int coordsEnd = aisResp.IndexOf("]", coordsIndex);
                            // Inside the code where we extract coordinates from API response
                            if (coordsEnd > coordsIndex)
                            {
                                // Extract the coordinates
                                string coordinates = aisResp.Substring(coordsIndex, coordsEnd - coordsIndex).Trim();
                                // Remove brackets
                                coordinates = coordinates.Replace("[", "").Replace("]", "");
    
                                // Swap the order of coordinates (longitude, latitude to latitude, longitude)
                                string[] coordParts = coordinates.Split(',');
                                if (coordParts.Length == 2)
                                {
                                    // Reverse the order and join them back with a comma
                                    coordinates = coordParts[1].Trim() + ", " + coordParts[0].Trim();
                                }
    
                                Session["GPSCoordinates"] = coordinates;
                                gpsCoordinates = coordinates;
                            }
                        }
                    }
                    
                    aisReader.Close();
                    aisDataStream.Close();
                    aisResponse.Close();
                }
                catch (Exception ex)
                {
                    // Handle errors from the AIS API
                    Session["GPSCoordinates"] = "Koordinaatteja ei saatavilla: " + ex.Message;
                    gpsCoordinates = Session["GPSCoordinates"].ToString();
                }
            }
            else
            {
                Session["GPSCoordinates"] = "Ei saatavilla";
                gpsCoordinates = "Ei saatavilla";
            }
        }
        
        reader.Close();
        dataStream.Close();
        response.Close();
    }
    catch (Exception ex)
    {
        // Handle any errors from the API call
        shipDetails["Error fetching ships: " + ex.Message] = new Dictionary<string, string>();
    }
}

// Format dates for display
string formattedArrivalTime = "";
if (!string.IsNullOrEmpty(arrivalTime))
{
    if (arrivalTime == "Ei tietoa")
    {
        formattedArrivalTime = "Ei tietoa";
    }
    else
    {
        string timeValue = arrivalTime;
        bool isEstimated = false;
        
        // Check if it's an estimated time
        if (arrivalTime.EndsWith(" (arvioitu)"))
        {
            timeValue = arrivalTime.Replace(" (arvioitu)", "");
            isEstimated = true;
        }
        
        // Parse the date if it's in a valid format
        DateTime dt;
        if (DateTime.TryParse(timeValue, out dt))
        {
            formattedArrivalTime = dt.ToString("dd.MM.yyyy") + " klo " + dt.ToString("HH:mm");
            if (isEstimated)
            {
                formattedArrivalTime += " (arvioitu)";
            }
        }
    }
}

string formattedDepartureTime = "";
if (!string.IsNullOrEmpty(departureTime))
{
    if (departureTime == "Ei tietoa")
    {
        formattedDepartureTime = "Ei tietoa";
    }
    else
    {
        DateTime dt;
        if (DateTime.TryParse(departureTime, out dt))
        {
            formattedDepartureTime = dt.ToString("dd.MM.yyyy") + " klo " + dt.ToString("HH:mm");
        }
    }
}

string formattedPortArea = "";
if (!string.IsNullOrEmpty(portArea))
{
    formattedPortArea = (portArea == "Ei tietoa") ? "Ei tietoa" : portArea;
}
%>
            
            <p>
                <label for="ddlOptions"></label>
                <select class="satamavalikko" id="ddlOptions" name="ddlOptions">
                    <option value="" <%= selectedPort == "" ? "selected" : "" %>>Valitse satama</option>
                    <option value="FIHEL" <%= selectedPort == "FIHEL" ? "selected" : "" %>>Helsinki</option>
                    <option value="FIHKO" <%= selectedPort == "FIHKO" ? "selected" : "" %>>Hanko</option>
                    <option value="FITKU" <%= selectedPort == "FITKU" ? "selected" : "" %>>Turku</option>
                </select>
            </p>
			
			</td>
		</tr>
	<tr><td style="padding: 10px;"></td></tr>
		<tr>
			<td>
				<p class="satamateksti">Laiva </p>
				</td>
			<td>
            <p>
                <label for="ddlShips"></label>
                <select class="satamavalikko" id="ddlShips" name="ddlShips">
                    <% if (selectedPort == "") { %>
                        <option value="">Valitse laiva</option>
                    <% } else if (shipDetails.Count == 0) { %>
                        <option value="">Ei laivoja 24 tunnin aikana</option>
                    <% } else { %>
                        <option value="" <%= selectedShip == "" ? "selected" : "" %>>Valitse laiva</option>
                        <% foreach (string ship in shipDetails.Keys) { %>
                            <option value="<%= ship %>" <%= selectedShip == ship ? "selected" : "" %>><%= ship %></option>
                        <% } %>
                    <% } %>
                </select>
            </p>
          </td>
        </table>
<!--	Tästä kohtaan lomake kyselyn painike alkaa	-->
            <br>
            <p>
                <input class="paivitahaku" type="submit" id="btnRefresh" name="btnRefresh" value="Päivitä haku" />
            </p>

                    <img src="pinkki3.png" alt="Pinkki Yksisarvisen kaveri" width="200" height="200" style="margin-left:50px">


        </div>
    

<!--	Tästä kohtaan lomake kyselyn painike loppuu	-->


		  <div class="hero-content">

            <p class="yläteksti"> 
				Tiedot: 
			</p>
			<p class="hero-text"> 
				<div class="tiedot1">  
                Laivan nimi: <%= selectedShip %>
				<br>
                    <br>
				GPS Sijaintikoordinaatit: 
                    <br>
                    <%= gpsCoordinates %>
				<br>
				<br>
				Satamassa: <%= formattedPortArea %>
				<br>
				<br>
				Arvioitu saapumisaika: 
                    <br>
                    <%= formattedArrivalTime %>
				<br>
				<br>
				Arvioitu lähtöaika: 
                    <br>
                    <%= formattedDepartureTime %>
				<br>
				<br>
				Tyyppi: <%= vesselType %>
				<br>
				<br>
				Kansallisuus <%= shipNationality %> <%= GetCountryName(shipNationality) %>
				</div>
				<br>
            </p>    
		  </div>
		</div> 
      </section>
    </form>
</body>
</html>

<script runat="server">
    // Helper function to convert nationality code to country name
    public string GetCountryName(string code)
    {
        if (string.IsNullOrEmpty(code) || code == "Ei tietoa") return "";
        
        Dictionary<string, string> countries = new Dictionary<string, string>()
        {
            {"FI", "Suomi"},
            {"SE", "Ruotsi"},
            {"NO", "Norja"},
            {"DK", "Tanska"},
            {"DE", "Saksa"},
            {"EE", "Viro"},
            {"LV", "Latvia"},
            {"LT", "Liettua"},
            {"PL", "Puola"},
            {"RU", "Venäjä"},
            {"NL", "Alankomaat"},
            {"BE", "Belgia"},
            {"FR", "Ranska"},
            {"UK", "Iso-Britannia"},
            {"ES", "Espanja"},
            {"PT", "Portugali"},
            {"IT", "Italia"},
            {"GR", "Kreikka"},
            {"CY", "Kypros"},
            {"MT", "Malta"},
            {"BG", "Bulgaria"},
            {"RO", "Romania"},
            {"HR", "Kroatia"},
            {"SI", "Slovenia"},
            {"AT", "Itävalta"},
            {"HU", "Unkari"},
            {"CZ", "Tšekki"},
            {"SK", "Slovakia"},
            {"IE", "Irlanti"},
            {"IS", "Islanti"},
            {"LU", "Luxemburg"},
            {"CH", "Sveitsi"},
            {"US", "Yhdysvallat"},
            {"CA", "Kanada"},
            {"MX", "Meksiko"},
            {"BR", "Brasilia"},
            {"AR", "Argentiina"},
            {"CL", "Chile"},
            {"CO", "Kolumbia"},
            {"PE", "Peru"},
            {"VE", "Venezuela"},
            {"AU", "Australia"},
            {"NZ", "Uusi-Seelanti"},
            {"JP", "Japani"},
            {"CN", "Kiina"},
            {"KR", "Etelä-Korea"},
            {"IN", "Intia"},
            {"SG", "Singapore"},
            {"MY", "Malesia"},
            {"TH", "Thaimaa"},
            {"ID", "Indonesia"},
            {"PH", "Filippiinit"},
            {"ZA", "Etelä-Afrikka"},
            {"AG", "Antigua and Barbuda"},
            {"KN", "Greenland"},
            {"LR", "Liberia"},
            {"BS", "Bahamas"}
            
        };
        
        return countries.ContainsKey(code) ? countries[code] : code;
    }
</script>
