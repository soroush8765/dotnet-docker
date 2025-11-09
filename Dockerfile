# ---------- Build stage ----------
FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS build
WORKDIR /src

# Nur die Projektdatei zuerst kopieren und restore ausführen (schont den Cache)
COPY src.csproj ./
RUN dotnet restore src.csproj

# Jetzt den Rest des Quellcodes kopieren
COPY . ./
# (Optional) falls values.txt nicht im Projekt eingebunden ist, ist die COPY oben ausreichend

# Konkretes Projekt publishen
RUN dotnet publish src.csproj -c Release -o /out

# ---------- Runtime stage ----------
FROM mcr.microsoft.com/dotnet/core/aspnet:2.2
WORKDIR /app

# Der 2.2-Container hört standardmäßig nicht zwingend auf :80; sicherheitshalber setzen:
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

# Build-Output aus dem ersten Stage übernehmen
COPY --from=build /out ./

# (Nur falls du values.txt im Container brauchst und sie nicht schon im Publish-Output liegt)
COPY values.txt ./

ENTRYPOINT ["dotnet", "src.dll"]
