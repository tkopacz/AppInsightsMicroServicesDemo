using System;
using Microsoft.ApplicationInsights;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace MicroBOffice
{
    public static class ServiceBus
    {
        [FunctionName("BOfficeSBus")]
        public static void Run([ServiceBusTrigger("%ServiceBusTopicName%", "all", Connection = "ServiceBusConnectionString")]string mySbMsg, ILogger log)
        {
            TelemetryClient lClient = new TelemetryClient();

            lClient.TrackEvent("Custom Event BOfficeSBus.");

            log.LogInformation($"BOfficeSBus processed message: {mySbMsg}");
        }
    }
}
