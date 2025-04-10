<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="tyhja_6.WebForm1" %>

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
            
            // Handle refresh button click
            if (IsPostBack && Request.Form["btnRefresh"] != null)
            {
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
            
            // Ship names list for the second dropdown
            List<string> shipNames = new List<string>();
            
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
                    
                    int rivi = resp.IndexOf("\"portToVisit\" : \"" + satamakoodi);
                    while (rivi >= 0)
                    {
                        int lahtopaikka = resp.IndexOf("\"prevPort", rivi);
                        string lahtosatama = resp.Substring(lahtopaikka + 14, 2);
                        int saapAikaIx = resp.IndexOf("\"ata\" :", rivi);
                        int arvSaapAikaIx = resp.IndexOf("\"eta\" :", rivi);
                        string saapAika = resp.Substring(saapAikaIx, 15);
                        bool onTulossa = saapAika.Contains("null");
                        
                        if (lahtosatama != "FI" && onTulossa)
                        {
                            int laivanpaikka = resp.IndexOf("\"vesselName\" :", rivi) + 16;
                            int laivanLoppu = resp.IndexOf(",", laivanpaikka);
                            string laivanNimi = resp.Substring(laivanpaikka, laivanLoppu - 1 - laivanpaikka);
                            
                            // Add ship name to our list instead of writing directly to response
                            shipNames.Add(laivanNimi);
                        }
                        
                        rivi = resp.IndexOf("\"portToVisit\" : \"" + satamakoodi, rivi + 1);
                    }
                    
                    reader.Close();
                    dataStream.Close();
                    response.Close();
                }
                catch (Exception ex)
                {
                    // Handle any errors from the API call
                    shipNames.Add("Error fetching ships: " + ex.Message);
                }
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
                    <% } else if (shipNames.Count == 0) { %>
                        <option value="">Ei laivoja valittavana</option>
                    <% } else { %>
                        <option value="" <%= selectedShip == "" ? "selected" : "" %>>Valitse laiva</option>
                        <% foreach (string ship in shipNames) { %>
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
    </form>

<!--	Tästä kohtaan lomake kyselyn painike loppuu	-->


		  <div class="hero-content">

            <p class="yläteksti"> 
				Tiedot: 
			</p>
			<p class="hero-text"> 
				<div class="tiedot1">
				<br>
				GPS Sijaintikoordinaatit
				<br>
				<br>
				[SATAMASSA: (SATAMA)]
				<br>
				(jos satamassa)
				<br>
				<br>
				Saapunut: 19.2.2025
				<br>
				(jos saapunut)
				<br>
				<br>
				Lähtöaika: 20.2.2025 klo 20
				<br>
				Oletettu saapumisaika: 20.2.2025 klo 23
				<br>
				<br>
				Tyyppi: Rahti
				<br>
				<br>
				Kansallisuus GER - Saksa
				</div>
				<br>
            </p>    
		  </div>
		</div> 
      </section>
</body>
</html>
