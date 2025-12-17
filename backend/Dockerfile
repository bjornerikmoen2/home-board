FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project files
COPY ["src/HomeBoard.Api/HomeBoard.Api.csproj", "HomeBoard.Api/"]
COPY ["src/HomeBoard.Domain/HomeBoard.Domain.csproj", "HomeBoard.Domain/"]
COPY ["src/HomeBoard.Infrastructure/HomeBoard.Infrastructure.csproj", "HomeBoard.Infrastructure/"]

# Restore dependencies
RUN dotnet restore "HomeBoard.Api/HomeBoard.Api.csproj"

# Copy all source files
COPY src/ .

# Build
WORKDIR "/src/HomeBoard.Api"
RUN dotnet build "HomeBoard.Api.csproj" -c Release -o /app/build

# Publish
FROM build AS publish
RUN dotnet publish "HomeBoard.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Final stage
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Development

ENTRYPOINT ["dotnet", "HomeBoard.Api.dll"]
