using System;
using Microsoft.Azure.Cosmos;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Azure.ServiceBus;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

[assembly: FunctionsStartup(typeof(MicroBOffice.Startup))]
namespace MicroBOffice
{
    public class Startup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            builder.Services.AddLogging(loggingBuilder =>
            {
                loggingBuilder.AddFilter(level => true);
            });
            
            builder.Services.AddSingleton<ITopicClient>(GetServiceBusTopic);
        }

        private ITopicClient GetServiceBusTopic(IServiceProvider options)
        {
            string ServiceBusConnectionString = "<TODO: Get Service Bus connections string from Env Variable>";
            string TopicName = Environment.GetEnvironmentVariable("SB:TopicName");
            TopicClient _topicClient = new TopicClient(ServiceBusConnectionString, TopicName);

            return _topicClient;
        }
    }
}
