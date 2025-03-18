<%@ Page Language="C#" 
    AutoEventWireup="true" 
    CodeBehind="hakukentta.aspx.cs" 
    Inherits="hakukentta2.Form1" %>

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
							<form class="satama" id="class2" runat="server" method="post" action="hakukentta">
								<select class="satamavalikko">
									<option value="">Valitse satama</option>
																		
										<%
										int i = 0;
										string[] alukset = { "Viking2_asp", "Adele_asp", "Alisia_asp", "Pekka_asp" };
										while (i < alukset.Length)
										{
											Response.Write ("<option value=\"");
											
											Response.Write (alukset[i]);
											Response.Write ("\">");
											Response.Write (alukset[i]);
											Response.Write ("</options>");
											

											++i;
										}
									%>

									<option value="Helsinki">Helsinki</option>

									<option value="Tukholma">Tukholma</option>
									
									<option value="Riika">Riika</option>
									
									<option value="Tallinna">Tallinna</option>
								
								</select>
						</td>
					</tr>
					<tr><td style="padding: 10px;"></td></tr>
					<tr>
						<td>
						<p class="satamateksti">Laiva </p>
						</td>
					<td>
							<select class="laivavalikko">
								<option value="">Valitse laiva</option>
								
								<option value="Viking2">Viking2</option>
								
								<option value="Adele">Adele</option>
								
								<option value="Alisia">Alisia</option>
								
								<option value="Pekka">Pekka</option>
							</select>
						</form>
					</td>
				</table>

<!--	Tästä kohtaan lomake kyselyn täyttäminen loppuu	-->

<!--	Tästä kohtaan lomake kyselyn painike alkaa	-->

				
				<br>
					<button class="paivitahaku">Päivitä haku</button>
				<br>
				<br>

<!--	Tästä kohtaan lomake kyselyn painike loppuu	-->

					<img src="pinkki3.png" alt="Pinkki Yksisarvisen kaveri" width="200" height="200" style="margin-left:50px">

				</div>
			
		  <div class="hero-content">

            <p class="yläteksti"> 
				Tiedot: 
			</p>
			<p class="hero-text"> 
				<div class="tiedot1">
                [LAIVAN NIMI]
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
