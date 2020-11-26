FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src

# copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore "MicroAlerts.csproj"

COPY . ./
WORKDIR "/src"
RUN dotnet build "MicroAlerts.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "MicroAlerts.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MicroAlerts.dll"]