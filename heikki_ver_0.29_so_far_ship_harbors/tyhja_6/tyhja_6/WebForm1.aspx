<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="tyhja_6.WebForm1" %>

<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Finnish Ports and Ships API Integration</title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <h2>Finnish Ports and Ships API Integration</h2>
            
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
                <strong>Counter Value: <%= Session["Counter"] %></strong>
            </p>
            
            <p>
                <strong>Selected Port Code: <%= selectedPort %></strong>
            </p>
            
            <p>
                <strong>Selected Ship: <%= selectedShip %></strong>
            </p>
            
            <p>
                <label for="ddlOptions">Select Port:</label>
                <select id="ddlOptions" name="ddlOptions">
                    <option value="" <%= selectedPort == "" ? "selected" : "" %>>Select a port</option>
                    <option value="FIHEL" <%= selectedPort == "FIHEL" ? "selected" : "" %>>Helsinki</option>
                    <option value="FIHKO" <%= selectedPort == "FIHKO" ? "selected" : "" %>>Hanko</option>
                    <option value="FITKU" <%= selectedPort == "FITKU" ? "selected" : "" %>>Turku</option>
                </select>
            </p>
            
            <p>
                <label for="ddlShips">Select Ship:</label>
                <select id="ddlShips" name="ddlShips">
                    <% if (selectedPort == "") { %>
                        <option value="">Please select a port first</option>
                    <% } else if (shipNames.Count == 0) { %>
                        <option value="">No ships available for this port</option>
                    <% } else { %>
                        <option value="" <%= selectedShip == "" ? "selected" : "" %>>Select a ship</option>
                        <% foreach (string ship in shipNames) { %>
                            <option value="<%= ship %>" <%= selectedShip == ship ? "selected" : "" %>><%= ship %></option>
                        <% } %>
                    <% } %>
                </select>
            </p>
            
            <p>
                <input type="submit" id="btnRefresh" name="btnRefresh" value="Refresh Page" />
            </p>
        </div>
    </form>
</body>
</html>
