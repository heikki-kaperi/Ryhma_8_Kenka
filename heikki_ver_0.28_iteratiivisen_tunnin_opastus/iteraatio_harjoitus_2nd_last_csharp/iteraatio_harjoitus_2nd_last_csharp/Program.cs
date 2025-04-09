using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Runtime.Remoting.Messaging;
using System.Text;
using System.Threading.Tasks;

namespace iteraatio_harjoitus_2nd_last_csharp
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Press 'Enter' to make web request");
            Console.ReadLine();
            
            StringWriter writer = new StringWriter();
            
            HttpWebRequest myRequest =
                (HttpWebRequest)WebRequest.Create(@"https://meri.digitraffic.fi/api/port-call/v1/port-calls");

            myRequest.AutomaticDecompression = DecompressionMethods.GZip;
            WebResponse response = myRequest.GetResponse();

            Stream dataStream = response.GetResponseStream();

            StreamReader reader = new StreamReader(dataStream);


            string resp = reader.ReadToEnd();

            string satamakoodi = "FIHKO";

            int rivi = resp.IndexOf("\"portToVisit\" : \"" + satamakoodi);
            Console.WriteLine(rivi);
            Console.ReadLine();
            while (rivi >= 0)
            {
                int lahtopaikka = resp.IndexOf("\"prevPort", rivi);
                string lahtosatama = resp.Substring(lahtopaikka + 14, 2);
                Console.WriteLine(resp.Substring(lahtopaikka + 14, 5));
                Console.ReadLine();

                int saapAikaIx = resp.IndexOf("\"ata\" :", rivi);
                int arvSaapAikaIx = resp.IndexOf("\"eta\" :", rivi);

                string saapAika = resp.Substring(saapAikaIx, 15);
                bool onTulossa = saapAika.Contains("null");
                if (lahtosatama != "FI" && onTulossa)
                {
                    int laivanpaikka = resp.IndexOf("\"vesselName\" :", rivi) + 16;
                    int laivanLoppu = resp.IndexOf(",", laivanpaikka);

                    string laivanNimi = resp.Substring(laivanpaikka, laivanLoppu - 1 - laivanpaikka);
                    Console.WriteLine(laivanNimi);
                    Console.ReadLine();
                }

                rivi = resp.IndexOf("\"portToVisit\" : \"" + satamakoodi, rivi + 1);
                Console.WriteLine(rivi);
                Console.ReadLine();
            }
        }
    }
}
