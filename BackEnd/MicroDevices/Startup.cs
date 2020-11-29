﻿using System;
using Microsoft.Azure.Cosmos;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Azure.ServiceBus;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

[assembly: FunctionsStartup(typeof(MicroDevices.Startup))]
namespace MicroDevices
{
    public class Startup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            builder.Services.AddLogging(loggingBuilder =>
            {
                loggingBuilder.AddFilter(level => true);
            });

            builder.Services.AddSingleton<Container>(GetContainer);
            builder.Services.AddSingleton<ITopicClient>(GetServiceBusTopic);
        }

        private Container GetContainer(IServiceProvider options)
        {
            var lConnectionString = Environment.GetEnvironmentVariable("Cosmos:ConnectionString");
            var lCosmosDbName = Environment.GetEnvironmentVariable("Cosmos:DbName");
            var lCosmosDbContainerName = Environment.GetEnvironmentVariable("Cosmos:DbContainerName");
            var lCosmosDbPartionKey = Environment.GetEnvironmentVariable("Cosmos:DbPartitionKey");

            var lClient = new CosmosClient(lConnectionString, new CosmosClientOptions
            {
                ConnectionMode = ConnectionMode.Direct
            });

            lClient.CreateDatabaseIfNotExistsAsync(lCosmosDbName).Wait();
            var lDb = lClient.GetDatabase(lCosmosDbName);
            lDb.CreateContainerIfNotExistsAsync(lCosmosDbContainerName, lCosmosDbPartionKey).Wait();

            return lDb.GetContainer(lCosmosDbContainerName);
        }

        private ITopicClient GetServiceBusTopic(IServiceProvider options)
        {
            string ServiceBusConnectionString = Environment.GetEnvironmentVariable("SB:ConnectionString");
            string TopicName = Environment.GetEnvironmentVariable("SB:TopicName");
            TopicClient _topicClient = new TopicClient(ServiceBusConnectionString, TopicName);

            return _topicClient;
        }
    }
}
