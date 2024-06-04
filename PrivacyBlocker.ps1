# Function to add telemetry domains to the hosts file
function Add-DomainsToHostsFile {
    param (
        [string]$hostsFilePath,
        [string[]]$domains,
        [string]$comment = "x.com/oqullcn"
    )

    # Define the hosts file encoding
    $hostsFileEncoding = [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]::Utf8

    # Define the blocking entries for both IPv4 and IPv6
    $blockingHostsEntries = @(
        @{ AddressType = "IPv4"; IPAddress = '0.0.0.0'; },
        @{ AddressType = "IPv6"; IPAddress = '::1'; }
    )

    try {
        $isHostsFilePresent = Test-Path -Path $hostsFilePath -PathType Leaf -ErrorAction Stop
    } catch {
        Write-Error "Failed to check hosts file existence. Error: $_"
        exit 1
    }

    if (-Not $isHostsFilePresent) {
        Write-Output "Creating a new hosts file at $hostsFilePath."
        try {
            New-Item -Path $hostsFilePath -ItemType File -Force -ErrorAction Stop | Out-Null
            Write-Output "Successfully created the hosts file."
        } catch {
            Write-Error "Failed to create the hosts file. Error: $_"
            exit 1
        }
    }

    foreach ($domain in $domains) {
        foreach ($blockingEntry in $blockingHostsEntries) {
            Write-Output "Processing addition for $($blockingEntry.AddressType) entry for domain $domain."
            try {
                $hostsFileContents = Get-Content -Path $hostsFilePath -Raw -Encoding $hostsFileEncoding -ErrorAction Stop
            } catch {
                Write-Error "Failed to read the hosts file. Error: $_"
                continue
            }

            $hostsEntryLine = "$($blockingEntry.IPAddress)`t$domain $([char]35) $comment"

            if ((-Not [String]::IsNullOrWhiteSpace($hostsFileContents)) -And ($hostsFileContents.Contains($hostsEntryLine))) {
                Write-Output "Skipping, entry already exists for domain $domain."
                continue
            }

            try {
                Add-Content -Path $hostsFilePath -Value $hostsEntryLine -Encoding $hostsFileEncoding -ErrorAction Stop
                Write-Output "Successfully added the entry for domain $domain."
            } catch {
                Write-Error "Failed to add the entry for domain $domain. Error: $_"
                continue
            }
        }
    }
}

# Function to block telemetry IPs via Windows Firewall
function Block-TelemetryIPs {
    param (
        [string[]]$ips
    )

    # Remove any existing rule with the same name to avoid duplicates
    Remove-NetFirewallRule -DisplayName "Block Telemetry IPs" -ErrorAction SilentlyContinue

    # Create a new firewall rule to block the provided IP addresses
    New-NetFirewallRule -DisplayName "Block Telemetry IPs" -Direction Outbound -Action Block -RemoteAddress ([string[]]$ips)
}

# Define the hosts file path
$hostsFilePath = "$env:SystemRoot\System32\drivers\etc\hosts"

$domains = @(
    "184-86-53-99.deploy.static.akamaitechnologies.com",
    "a-0001.a-msedge.net",
    "a-0002.a-msedge.net",
    "a-0003.a-msedge.net",
    "a-0004.a-msedge.net",
    "a-0005.a-msedge.net",
    "a-0006.a-msedge.net",
    "a-0007.a-msedge.net",
    "a-0008.a-msedge.net",
    "a-0009.a-msedge.net",
    "a.ads1.msn.com",
    "a.ads2.msads.net",
    "a.ads2.msn.com",
    "a.rad.msn.com",
    "a-msedge.net",
    "a1621.g.akamai.net",
    "a1856.g2.akamai.net",
    "a1961.g.akamai.net",
    "a248.e.akamai.net",
    "a978.i6g1.akamai.net",
    "ac3.msn.com",
    "ad.doubleclick.net",
    "adnexus.net",
    "adnxs.com",
    "ads.msn.com",
    "ads1.msads.net",
    "ads1.msn.com",
    "aidps.atdmt.com",
    "aka-cdn-ns.adtech.de",
    "any.edge.bing.com",
    "api.msn.com",
    "arc.msn.com",
    "assets.msn.com",
    "az361816.vo.msecnd.net",
    "az512334.vo.msecnd.net",
    "az667904.vo.msecnd.net",
    "b.ads1.msn.com",
    "b.ads2.msads.net",
    "b.rad.msn.com",
    "bingads.microsoft.com",
    "browser.events.data.microsoft.com",
    "browser.events.data.msn.com",
    "browser.pipe.aria.microsoft.com",
    "bs.serving-sys.com",
    "c.atdmt.com",
    "c.msn.com",
    "cdn.atdmt.com",
    "cds26.ams9.msecn.net",
    "ceuswatcab01.blob.core.windows.net",
    "ceuswatcab02.blob.core.windows.net",
    "choice.microsoft.com",
    "choice.microsoft.com.nsatc.net",
    "client.wns.windows.com",
    "compatexchange.cloudapp.net",
    "corpext.msitadfs.glbdns2.microsoft.com",
    "corp.sts.microsoft.com",
    "cs1.wpc.v0cdn.net",
    "cs11.wpc.v0cdn.net",
    "cs1137.wpc.gammacdn.net",
    "data.microsoft.com",
    "data.msn.com",
    "db3aqu.atdmt.com",
    "dc.services.visualstudio.com",
    "df.telemetry.microsoft.com",
    "diagnostics.support.microsoft.com",
    "dmd.metaservices.microsoft.com",
    "e2835.dspb.akamaiedge.net",
    "e3843.g.akamaiedge.net",
    "e7341.g.akamaiedge.net",
    "e7502.ce.akamaiedge.net",
    "e8218.ce.akamaiedge.net",
    "e87.dspb.akamaidege.net",
    "e9483.a.akamaiedge.net",
    "ec.atdmt.com",
    "edge.microsoft.com",
    "eaus2watcab01.blob.core.windows.net",
    "eaus2watcab02.blob.core.windows.net",
    "events-dc1-gfe.nvidia.com",
    "fe2.update.microsoft.com.akadns.net",
    "feedback.microsoft-hohm.com",
    "feedback.search.microsoft.com",
    "feedback.windows.com",
    "fd.api.iris.microsoft.com",
    "flightingserviceweurope.cloudapp.net",
    "flex.msn.com",
    "functional.events.data.microsoft.com",
    "g.msn.com",
    "gfswl.geforce.com",
    "googleads.g.doubleclick.net",
    "h1.msn.com",
    "h2.msn.com",
    "hostedocsp.globalsign.com",
    "hubspot.net.edgekey.net",
    "hubspot.net.edge.net",
    "i1.services.social.microsoft.com",
    "i1.services.social.microsoft.com.nsatc.net",
    "inference.location.live.net",
    "insiderppe.cloudapp.net",
    "insiderservice.microsoft.com",
    "insiderservice.trafficmanager.net",
    "location-inference-westus.cloudapp.net",
    "live.rads.msn.com",
    "login.live.com",
    "m.adnxs.com",
    "m.hotmail.com",
    "modern.watson.data.microsoft.com",
    "msedge.net",
    "msftconnecttest.com",
    "msnbot-65-55-108-23.search.msn.com",
    "msntest.serving-sys.com",
    "mucp.api.account.microsoft.com",
    "ntp.msn.com",
    "oca.microsoft.com",
    "oca.telemetry.microsoft.com",
    "oca.telemetry.microsoft.com.nsatc.net",
    "onesettings-db5.metron.live.nsatc.net",
    "outlookads.live.com",
    "pagead46.l.doubleclick.net",
    "pricelist.skype.com",
    "pre.footprintpredict.com",
    "preview.msn.com",
    "query.prod.cms.rt.microsoft.com",
    "rad.live.com",
    "rad.msn.com",
    "redir.metaservices.microsoft.com",
    "reports.wes.df.telemetry.microsoft.com",
    "ris.api.iris.microsoft.com",
    "s.gateway.messenger.live.com",
    "s0.2mdn.net",
    "sls.update.microsoft.com",
    "sls.update.microsoft.com.akadns.net",
    "sls.update.microsoft.com.nsatc.net",
    "scorecardresearch.com",
    "scus-breeziest-in.cloudapp.net",
    "secure.adnxs.com",
    "secure.flashtalking.com",
    "self.events.data.microsoft.com",
    "services.wes.df.telemetry.microsoft.com",
    "settings-sandbox.data.microsoft.com",
    "settings-win.data.microsoft.com",
    "settings-ssl.xboxlive.com",
    "settings-ssl.xboxlive.com-c.edgekey.net",
    "settings-ssl.xboxlive.com-c.edgekey.net.globalredir,.akadns.net"
    "sl.update.microsoft.com",
    "spm.df.telemetry.microsoft.com",
    "spm.telemetry.microsoft.com",
    "sqm.telemetry.microsoft.com.nsatc.net",
    "static.2mdn.net",
    "staticview.msn.com",
    "stats.g.doubleclick.net",
    "stats.l.doubleclick.net",
    "statsfe1.ws.microsoft.com",
    "statsfe2.update.microsoft.com.akadns.net",
    "statsfe2.ws.microsoft.com",
    "storeedgefd.dsx.mp.microsoft.com",
    "survey.watson.microsoft.com",
    "telecommand.telemetry.microsoft.com",
    "telecommand.telemetry.microsoft.com.nsatc.net",
    "telemetry.appex.bing.net",
    "telemetry-dce.gfe.nvidia.com",
    "telemetry.microsoft.com",
    "telemetry.nvidia.com",
    "telemetry.urs.microsoft.com",
    "teams.events.data.microsoft.com",
    "ui.skype.com",
    "umwatson.events.data.microsoft.com",
    "umwatsonc.events.data.microsoft.com",
    "us-v10c.events.data.microsoft.com",
    "v10.events.data.microsoft.com",
    "v10.vortex-win.data.microsoft.com",
    "v10c.events.data.microsoft.com",
    "visualstudio-devdiv-c2s.msedge.net",
    "vortex.data.microsoft.com",
    "vortex-sandbox.data.microsoft.com",
    "vortex-win.data.microsoft.com",
    "vortex-bn2.metron.live.com.nsatc.net",
    "vortex-cy2.metron.live.com.nsatc.net",
    "watson.events.data.microsoft.com",
    "watson.live.com",
    "watson.microsoft.com",
    "watson.ppe.telemetry.microsoft.com",
    "watson.telemetry.microsoft.com",
    "watson.telemetry.microsoft.com.nsatc.net",
    "weus2watcab01.blob.core.windows.net",
    "weus2watcab02.blob.core.windows.net",
    "wes.df.telemetry.microsoft.com",
    "win10.ipv6.microsoft.com",
    "www.bingads.microsoft.com",
    "www-google-analytics.l.google.com",
    "www.go.microsoft.akadns.net",
    "www.msn.com",
    "www.telecommandsvc.microsoft.com",
    "id.google.com",
    "jnn-pa.googleapis.com",
    "pagead2.googlesyndication.com",
    "fundingchoicesmessages.google.com",
    "contributor.google.com",
    "www.googletagmanager.com",
    "securepubads.g.doubleclick.net",
    "pubads.g.doubleclick.net",
    "imasdk.googleapis.com",
    "tpc.googlesyndication.com",
    "www.google-analytics.com",
    "incoming.telemetry.mozilla.org",
    "crash-stats.mozilla.com",
    "crash-reports.mozilla.com",
    "contile.services.mozilla.com",
    "telemetry.mozilla.org",
    "events.mozilla.org",
    "detection.telemetry.mozilla.org",
    "services.mozilla.com",
    "snippets.mozilla.com",
    "beacon.mozilla.org",
    "craftrise.com",
    "craftrise.com.tr"
)

$ips = @(
    "2.22.61.43",
    "2.22.61.66",
    "8.36.80.197",
    "8.36.80.224",
    "8.36.80.252",
    "8.36.113.118",
    "8.36.113.141",
    "8.36.80.230",
    "8.36.80.231",
    "8.36.113.126",
    "8.36.80.195",
    "8.36.80.217",
    "8.36.80.237",
    "8.36.80.246",
    "8.36.113.116",
    "8.36.113.139",
    "8.36.80.244",
    "13.68.31.193",
    "13.66.56.243",
    "13.68.82.8",
    "13.70.180.171",
    "13.73.26.107",
    "13.78.130.220",
    "13.78.232.226",
    "13.78.233.133",
    "13.88.28.53",
    "13.92.194.212",
    "20.44.86.43",
    "20.189.74.153",
    "23.99.49.121",
    "23.102.4.253",
    "23.102.21.4",
    "23.103.182.126",
    "23.218.212.69",
    "40.68.222.212",
    "40.69.153.67",
    "40.70.184.83",
    "40.70.220.248",
    "40.70.221.249",
    "40.77.228.47",
    "40.77.228.87",
    "40.77.228.92",
    "40.77.232.101",
    "40.79.85.125",
    "40.90.221.9",
    "40.115.3.210",
    "40.115.119.185",
    "40.119.211.203",
    "40.124.34.70",
    "51.140.40.236",
    "51.140.157.153",
    "51.143.111.7",
    "51.143.111.81",
    "52.114.6.46",
    "52.114.6.47",
    "52.114.7.36",
    "52.114.7.37",
    "52.114.7.38",
    "52.114.7.39",
    "52.114.32.5",
    "52.114.32.6",
    "52.114.32.7",
    "52.114.32.8",
    "52.114.32.24",
    "52.114.32.25",
    "52.114.36.1",
    "52.114.36.2",
    "52.114.36.3",
    "52.114.36.4",
    "52.114.74.43",
    "52.114.74.44",
    "52.114.74.45",
    "52.114.75.78",
    "52.114.75.79",
    "52.114.75.149",
    "52.114.75.150",
    "52.114.76.34",
    "52.114.76.35",
    "52.114.76.37",
    "52.114.77.33",
    "52.114.77.34",
    "52.114.77.137",
    "52.114.77.164",
    "52.114.88.19",
    "52.114.88.20",
    "52.114.88.21",
    "52.114.88.22",
    "52.114.88.28",
    "52.114.88.29",
    "52.114.128.7",
    "52.114.128.8",
    "52.114.128.9",
    "52.114.128.10",
    "52.114.128.43",
    "52.114.128.44",
    "52.114.128.58",
    "52.114.132.14",
    "52.114.132.20",
    "52.114.132.21",
    "52.114.132.22",
    "52.114.132.23",
    "52.114.132.73",
    "52.114.132.74",
    "52.114.158.50",
    "52.114.158.51",
    "52.114.158.52",
    "52.114.158.53",
    "52.114.158.91",
    "52.114.158.92",
    "52.114.158.102",
    "52.138.204.217",
    "52.138.216.83",
    "52.155.172.105",
    "52.157.234.37",
    "52.158.208.111",
    "52.164.241.205",
    "52.169.189.83",
    "52.170.83.19",
    "52.174.22.246",
    "52.178.147.240",
    "52.178.151.212",
    "52.178.178.16",
    "52.178.223.23",
    "52.183.114.173",
    "52.229.39.152",
    "52.230.85.180",
    "52.236.42.239",
    "52.236.43.202",
    "64.4.54.254",
    "65.39.117.230",
    "65.52.108.33",
    "65.55.108.23",
    "65.52.100.7",
    "65.52.100.9",
    "65.52.100.11",
    "65.52.100.91",
    "65.52.100.92",
    "65.52.100.93",
    "65.52.100.94",
    "65.52.161.64",
    "65.55.29.238",
    "65.55.44.51",
    "65.55.44.54",
    "65.55.44.108",
    "65.55.44.109",
    "65.55.83.120",
    "65.55.113.11",
    "65.55.113.12",
    "65.55.113.13",
    "65.55.176.90",
    "65.55.252.43",
    "65.55.252.63",
    "65.55.252.70",
    "65.55.252.71",
    "65.55.252.72",
    "65.55.252.93",
    "65.55.252.190",
    "65.55.252.202",
    "66.119.147.131",
    "104.26.8.156",
    "104.26.9.156",
    "104.41.207.73",
    "104.43.137.66",
    "104.43.139.21",
    "104.43.140.223",
    "104.43.228.53",
    "104.43.228.202",
    "104.43.237.169",
    "104.45.11.195",
    "104.45.214.112",
    "104.46.1.211",
    "104.46.38.64",
    "104.210.4.77",
    "104.210.40.87",
    "104.210.212.243",
    "104.214.35.244",
    "104.214.78.152",
    "131.253.6.87",
    "131.253.6.103",
    "131.253.40.37",
    "134.170.30.202",
    "134.170.30.203",
    "134.170.30.204",
    "134.170.30.221",
    "134.170.52.151",
    "134.170.235.16",
    "137.116.81.24",
    "157.56.74.250",
    "157.56.91.77",
    "157.56.106.184",
    "157.56.106.185",
    "157.56.106.189",
    "157.56.113.217",
    "157.56.121.89",
    "157.56.124.87",
    "157.56.149.250",
    "157.56.194.72",
    "157.56.194.73",
    "157.56.194.74",
    "168.61.24.141",
    "168.61.146.25",
    "168.61.149.17",
    "168.61.172.71",
    "168.62.187.13",
    "168.63.100.61",
    "168.63.108.233",
    "172.67.71.187",
    "184.86.53.99",
    "191.236.155.80",
    "191.237.218.239",
    "191.239.50.18",
    "191.239.50.77",
    "191.239.52.100",
    "191.239.54.52",
    "204.79.197.200",
    "207.68.166.254",
    "216.228.121.209"
)

# Add domains to the hosts file
Add-DomainsToHostsFile -hostsFilePath $hostsFilePath -domains $domains

# Block telemetry IPs via firewall
Block-TelemetryIPs -ips $ips