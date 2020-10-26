using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace MicroBOffice
{
    public class CharacterEntity
    {
        [JsonProperty(PropertyName = "id")]
        public string Id { get; set; }

        [JsonProperty(PropertyName = "when")]
        public DateTime When { get; set; }

        [JsonProperty(PropertyName = "who")]
        public string Who { get; set; }

        [JsonProperty(PropertyName = "whoid")]
        public string WhoId { get; set; }

    }
}
