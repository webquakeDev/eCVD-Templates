<#-- ---- Begin eCVD ADVANCED template for IR829 -----
     ---- Version 2.01b ----------------------
     -----------------------------------------
     -- March 2022 Release                  --
     -- Support single and dual Radio       --
     -- Site to Site VPN                    --
-->


<#compress>

<#-- Set dumpAllVariables to true to dump all template variables
     in the config for debugging. This will also dump all passwords in
     clear text. -->
<#assign dumpAllVariables = false>

<#-- extract PID and SN from EID - ie. IR829-K9+FCW23510HKN -->
<#assign sublist 		= "${far.eid}"?split("+")[0..1]>
<#assign pid = sublist[0]>
<#assign model = pid[0..4]>
<#assign sn = sublist[1]>

<#if ! pid?starts_with("IR829")>
  ${provisioningFailed("This template is for IR829 and does not support ${pid}")}
</#if>

<#-- PLATFORM SPECIFIC VARIABLES -->
<#assign ether_if = "vlan10">
<#if pid?contains("2LTE")>
  <#assign cell_if1 = "Cellular 0/0">
  <#assign cell_if2 = "Cellular 1/0">
<#else>
  <#assign cell_if1 = "Cellular 0">
</#if>
<#assign cell_if1_contr = "Cellular 0">
<#assign isGpsEnabled = "true">
<#assign wgb_vlan = "50">
<#assign wgb_if = "Vlan${wgb_vlan}">
<#assign vpnTunnelIntf = "Tunnel2">

<#-- TEMPLATE CONSTANTS -->
<#assign umbrella_dns1_ip = "208.67.222.222">
<#assign umbrella_dns2_ip = "208.67.220.220">

<#-- VARIABLES INITIALIZATION -->
<#assign highestPriorityIfName = 1>
<#assign priorityIfNameTable = []>
<#assign isTunnelEnabledTable = []>
<#assign isCellIntTable = []>
<#assign isWGBIntTable = []>
<#assign EthernetPortPriority = 200>
<#assign WgbIntPriority = 200>
<#assign Cell2PortPriority = 200>
<#assign Cell1PortPriority = 200>


<#-- IP SLA destination IP addresses -->

<#assign ipslaDestIPaddress = [far.IcmpReachableIPaddress1!"4.2.2.1",
    far.IcmpReachableIPaddress2!"4.2.2.2",
    far.IcmpReachableIPaddress3!"9.9.9.10",
    far.IcmpReachableIPaddress4!"9.9.9.11"]>

<#-- Interface Menu -->
<#-- assign GigEthernet1_enabled = far..gigEthernet1!"true" -->
<#assign GigEthernet2_enabled = far.gigEthernet2!"true">
<#assign GigEthernet3_enabled = far.gigEthernet3!"true">
<#assign GigEthernet4_enabled = far.gigEthernet4!"true">

<#-- Allows the template to prompt for "admin" password.
     IoTOC will generate one by default during claim but
     can be changed here -->
<#-- may cause issues if not net, password NULL -->
<#-- assign adminPassword = far..adminPassword --->

<#-- WAN Menu -->

<#if section.wan_ethernet?has_content && section.wan_ethernet == "true">
  <#assign isEthernetEnable = "true">
  <#assign ethernetPriority = far.ethernetPriority>
<#else>
  <#assign isEthernetEnable = "false">
</#if>

<#if section.wan_wgb?has_content && section.wan_wgb == "true">
  <#assign isWgbEnable = "true">
  <#assign wgbPriority = far.wgbPriority>
<#else>
  <#assign isWgbEnable = "false">
</#if>

<#assign isFirstCell = "false">
<#assign isGpsEnabled = "true">
<#if section.wan_cellular1?has_content && section.wan_cellular1 == "true">
  <#assign isFirstCell = "true">
  <#if far.apn1?has_content && far.apn1 != "null">
    <#assign APN1			= far.apn1>
  </#if>
</#if>

<#assign isSecondCell = "false">
<#if section.wan_cellular2?has_content && section.wan_cellular2 == "true">
  <#assign isSecondCell = "true">
  <#if far.apn2?has_content && far.apn2 != "null">
    <#assign APN2 = far.apn2>
  </#if>
</#if>

<#-- LAN Menu -->
<#assign lanIP 		= "${far.lanIPAddress}"?split(".")>
<#assign lanNet 	= "${far.lanNetmask}"?split(".")>

<#-- Network Menu -->

<#-- Security Menu -->

<#-- Umbrella not supported on IR829 -->
<#assign isUmbrella = "false">

<#assign isNetFlow = "false">
<#if section.security_netflow?has_content && section.security_netflow == "true">
  <#assign isNetFlow = "true">
  <#if far.netflowCollectorIP?has_content>
    <#assign netflowCollectorIP = far.netflowCollectorIP>
  </#if>
</#if>

<#-- VPN Settings Menu -->
<#assign isPrimaryHeadEndEnable = "false">
<#assign isSecondaryHeadEndEnable = "false">
<#if section.vpn_primaryheadend?has_content && section.vpn_primaryheadend == "true">
  <#if far.herIpAddress?has_content && far.herPsk?has_content>
    <#assign herIpAddress 	= "${far.herIpAddress}">
    <#assign herPsk			    = "${far.herPsk}">
    <#assign isPrimaryHeadEndEnable = "true">
  </#if>
  <#if section.vpn_backupheadend?has_content && section.vpn_backupheadend == "true">
    <#if far.backupHerIpAddress?has_content && far.backupHerPsk?has_content>
      <#assign backupHerIpAddress = "${far.backupHerIpAddress}">
      <#assign backupHerPsk	= "${far.backupHerPsk}">
      <#assign isSecondaryHeadEndEnable = "true">
    </#if>
  </#if>
</#if>

<#-- Device Settings Menu -->
<#if far.localDomainName?has_content>
  <#assign domainName = "${far.localDomainName}">
<#else>
  <#assign domainName = "local">
</#if>

<#-- If no DNS specified, assign Umbrella DNS servers -->
<#assign umbrella_dns1_ip = "208.67.222.222">
<#assign umbrella_dns2_ip = "208.67.220.220">
<#assign dns1 = far.lanDNSIPAddress1!umbrella_dns1_ip>
<#assign dns2 = far.lanDNSIPAddress2!umbrella_dns2_ip>
<#assign DNSIP		= "${dns1} ${dns2}">

<#if far.ignition?has_content && far.ignition == "true">
  <#assign ignition 	= "true">
<#else>
  <#assign ignition 	= "false">
</#if>

<#-- Setting up time zone settings -->
<#if far.clockTZ?has_content>
  <#assign clockTZ = far.clockTZ>
<#else>
  <#assign clockTZ = "gmt">
</#if>

<#if far.ntpIP?has_content>
  <#assign ntpIP = far.ntpIP>
<#else>
  <#assign ntpIP = "time.nist.gov">
</#if>

<#-- Calculate Netmasks -->

<#function ipv4_to_binary ipaddr>
  <#assign bin_ip=[]>
  <#list ipaddr as lann>
    <#assign lan=lann?number>
    <#list 1..100 as y>
      <#if lan < 1 >
        <#if lan == 0>
          <#list 1..8 as s>
            <#assign bin_ip=bin_ip+["0"]>
          </#list>
	      </#if>
        <#if bin_ip?size % 8 != 0>
          <#list 1..8 as s>
	          <#assign bin_ip=bin_ip+["0"]>
	          <#if bin_ip?size % 8 == 0>
	            <#break>
            </#if>
	        </#list>
	      </#if>
        <#break>
      </#if>
      <#assign x=lan%2 st=x?string bin_ip=bin_ip+[st] lan=lan/2>
    </#list>
  </#list>
  <#return (bin_ip)>
</#function>

<#assign  lan_ip=[]  lan_netmask=[]>

<#-- Binary Conversion of LAN IP-->

<#assign lan_ip=ipv4_to_binary(lanIP)>
<#assign ip_bit = lan_ip?reverse>
<#assign lan_netmask=ipv4_to_binary(lanNet)>
<#assign subnet_bit=lan_netmask?reverse>

<#-- Logical AND operation between IP and NetMask-->

<#assign lan_netID=[]>
<#list ip_bit as rev_index>
<#if rev_index?string == "1" && subnet_bit[rev_index?index] == "1"><#assign lan_netID=lan_netID+["1"]></#if>
<#if rev_index?string == "1" && subnet_bit[rev_index?index] == "0"><#assign lan_netID=lan_netID+["0"]></#if>
<#if rev_index?string == "0" && subnet_bit[rev_index?index] == "1"><#assign lan_netID=lan_netID+["0"]></#if>
<#if rev_index?string == "0" && subnet_bit[rev_index?index] == "0"><#assign lan_netID=lan_netID+["0"]></#if>
</#list>
<#assign netid_bit=lan_netID?reverse>

<#--Binary to Decimal conversion of Logical AND product-->

<#assign netid=[]>
<#list netid_bit?chunk(8) as row> <#assign num=0 pow=1> <#list row as bit> <#assign num=num+pow*bit?number pow=pow*2> </#list>
<#assign netid=netid+[num]>
</#list>

<#--Network Address-->

<#assign lanNtwk = netid?join(".")?string>
<#assign lanWild = "${(255 - (lanNet[0])?number)?abs}.${(255 - (lanNet[1])?number)?abs}.${(255 - (lanNet[2])?number)?abs}.${(255 - (lanNet[3])?number)?abs}">

<#-- Configure timezone offset -->

<#assign TZ = { "anat":"+12", "sbt":"+11", "aest":"+10", "jst":"+9", "cst":"+8", "wib":"+7", "btt":"+6", "uzt":"+5", "gst":"+4", "msk":"+3", "cest":"+2", "bst":"+1", "gmt":"0", "cvt":"-1", "wgst":"-2", "art":"-3", "edt":"-4", "cdt":"-5", "mst":"-6", "pdt":"-7", "akdt":"-8", "hdt":"-9", "hst":"-10", "nut":"-11", "aeo":"-12" }>
<#assign offset = 0>
<#list TZ as x, y >
	<#if x == clockTZ>
		<#assign offset = y>
		<#break>
	</#if>
</#list>


<#if section.network_qos?has_content && section.network_qos == "true">
  <#assign isQosEnabled = "true">
  <#if far.qosBandwidth?has_content>
    <#assign qosBandwidth = far.qosBandwidth>
  </#if>
  <#if far.qos?has_content>
    <#assign qosPolicyTable = far.qos>
  </#if>
<#else>
  <#assign isQosEnabled = "false">
</#if>

<#-- Configure Device Settings -->

service tcp-keepalives-in
service tcp-keepalives-out
service timestamps debug datetime msec
service timestamps log datetime msec
service password-encryption
service call-home
!
!
clock timezone ${clockTZ} ${offset}
ntp server ${ntpIP}
!
ip domain name ${domainName}
!
event manager directory user policy "flash:/managed/scripts"
!
ip dhcp pool subtended
    network ${lanNtwk} ${far.lanNetmask}
    default-router ${far.lanIPAddress}
    dns-server ${DNSIP}
    lease 0 0 10
!
vlan ${wgb_vlan}
!
interface ${wgb_if}
  ip address dhcp
  ip nat outside
  ip virtual-reassembly in
!
<#if far.lanIPAddressDHCPexcludeRangeStart?has_content && far.lanIPAddressDHCPexcludeRangeEnd?has_content>
  ip dhcp excluded-address ${far.lanIPAddressDHCPexcludeRangeStart} ${far.lanIPAddressDHCPexcludeRangeEnd}
</#if>
!
<#-- create users as defined in the template -->
<#if far.Users?has_content>
  <#list far.Users as user >
    <#if user['userName']?has_content &&
          user['userPassword']?has_content &&
          user['userPriv']?has_content>
		  <#if user['userName'] == "admin">
		    <#-- "admin" user is already used by IoT OC, ignore -->
		    <#continue>
		  </#if>
      <#-- here we made sure to have username, password and pivillege defined -->
		  username ${user['userName']} privilege ${user['userPriv']} algorithm-type scrypt secret ${user['userPassword']}
    </#if>
  </#list>
</#if>
!
<#-- S2S VPN Configuration -->
!
<#if isPrimaryHeadEndEnable == "true" && herIpAddress?has_content && herPsk?has_content>
    crypto ikev2 authorization policy CVPN
 	    route set interface
 	    route accept any distance 70
!
    crypto ikev2 keyring Flex_key
!
    peer ${herIpAddress}
      address ${herIpAddress}
      identity key-id ${herIpAddress}
      pre-shared-key ${herPsk}
!
    <#if isSecondaryHeadEndEnable == "true">
		  <#if backupHerIpAddress?has_content && backupHerPsk?has_content>
        peer ${backupHerIpAddress}
        address ${backupHerIpAddress}
        identity key-id ${backupHerIpAddress}
        pre-shared-key ${backupHerPsk}
      </#if>
		</#if>
!
  crypto ikev2 profile CVPN_I2PF
    match identity remote key-id ${herIpAddress}
    <#if isSecondaryHeadEndEnable == "true">
      <#if backupHerIpAddress?has_content>
        match identity remote key-id ${backupHerIpAddress}
	    </#if>
    </#if>
    identity local email ${sn}@iotspdev.io
    authentication remote pre-share
    authentication local pre-share
    keyring local Flex_key
    dpd 29 2 periodic
    aaa authorization group psk list CVPN CVPN
!
!
crypto ipsec profile CVPN_IPS_PF
 set ikev2-profile CVPN_I2PF
!
!
interface ${vpnTunnelIntf}
 ip address negotiated
 ip mtu 1358
 ip nat outside
 ip tcp adjust-mss 1318
 tunnel source dynamic
 tunnel mode ipsec ipv4
 tunnel destination dynamic
 tunnel path-mtu-discovery
 tunnel protection ipsec profile CVPN_IPS_PF
!
crypto ikev2 client flexvpn ${vpnTunnelIntf}
  peer 1 ${herIpAddress}
  <#if isSecondaryHeadEndEnable == "true">
    peer 2 ${backupHerIpAddress}
  </#if>
  client connect ${vpnTunnelIntf}
!

<#-- Allows ESP from Head end so that Site to Site VPN passes through ZBFW -->
ip access-list extended permit-vpn
 permit esp any host ${herIpAddress}
 permit esp host ${herIpAddress} any
 <#if isSecondaryHeadEndEnable == "true">
  <#if backupHerIpAddress?has_content && backupHerPsk?has_content>
    permit esp any host ${backupHerIpAddress}
    permit esp host ${backupHerIpAddress} any
  </#if>
 </#if>
!
class-map type inspect match-any bypass-cm
 match access-group name permit-vpn

</#if>

 <#-- interface priorities -->

 <#list 1..4 as p>
   <#if isEthernetEnable == "true"
         && ether_if?? && ethernetPriority?has_content
         && ethernetPriority == p?string>
     <#assign priorityIfNameTable += [ether_if]>
     <#assign isTunnelEnabledTable += [far.enableTunnelOverEthernet!"false"]>
     <#assign isCellIntTable += ["false"]>
     <#assign isWGBIntTable += ["false"]>
     <#assign EthernetPortPriority = 100+p>
   <#elseif isWgbEnable == "true"
         && wgb_if?has_content && wgbPriority?has_content
         && wgbPriority == p?string>
     <#assign priorityIfNameTable += [wgb_if]>
     <#assign isTunnelEnabledTable += [far.enableTunnelOverWGB!"false"]>
     <#assign isCellIntTable += ["false"]>
     <#assign isWGBIntTable += ["true"]>
     <#assign WgbIntPriority = 100+p>
   <#elseif isFirstCell == "true"
         && cell_if1?? && far.firstCellularIntPriority?has_content
         && far.firstCellularIntPriority == p?string>
     <#assign priorityIfNameTable += [cell_if1]>
     <#assign isTunnelEnabledTable += [far.enableTunnelOverCell1!"false"]>
     <#assign isCellIntTable += ["true"]>
     <#assign isWGBIntTable += ["false"]>
     <#assign Cell1PortPriority = 100+p>
   <#elseif isSecondCell == "true"
         && cell_if2?? && far.secondCellularIntPriority?has_content
         && far.secondCellularIntPriority == p?string>
     <#assign priorityIfNameTable += [cell_if2]>
     <#assign isTunnelEnabledTable += [far.enableTunnelOverCell2!"false"]>
     <#assign isCellIntTable += ["true"]>
     <#assign isWGBIntTable += ["false"]>
     <#assign Cell2PortPriority = 100+p>
   </#if>
 </#list>

 <#if priorityIfNameTable?size <=0>
   <#-- No interface in the priority table
        This scenario should never happen -->
    ${provisioningFailed("Need at least one WAN interface enabled on ${far.eid}")}
 <#else>
   <#-- Iterate over interface table list, by configured priority from 1 to 4 -->
   <#list 0 .. (priorityIfNameTable?size-1) as p>
     !
     ! ***** ${priorityIfNameTable[p]} configuration *****
     !
     <#-- Config for Cell interface are slightly different -->
     <#if isCellIntTable[p] == "true">
       track ${p+10} interface ${priorityIfNameTable[p]} line-protocol
       ip route 0.0.0.0 0.0.0.0 ${priorityIfNameTable[p]} ${70+p} track ${p+40}
       ip route ${ipslaDestIPaddress[p]} 255.255.255.255 ${priorityIfNameTable[p]} track ${p+10}
     <#else>
       ip route 0.0.0.0 0.0.0.0 ${priorityIfNameTable[p]} dhcp ${70+p}
       ip route ${ipslaDestIPaddress[p]} 255.255.255.255 dhcp
     </#if>
     ip route ${ipslaDestIPaddress[p]} 255.255.255.255 Null0 3
     ip sla ${p+40}
       <#-- Cell interface do not require the source for the SLA -->
       <#if isCellIntTable[p] == "true">
       	icmp-echo ${ipslaDestIPaddress[p]}
         frequency 50
       <#else>
         icmp-echo ${ipslaDestIPaddress[p]} source-interface ${priorityIfNameTable[p]}
         frequency 10
       </#if>
     !
     !
     ip sla schedule ${p+40} life forever start-time now
       track ${p+40} ip sla ${p+40} reachability
     event manager applet failover_${p+40}
       event track ${p+40} state any
       action 0.1 syslog msg "${priorityIfNameTable[p]} connectivity change, clearing NAT translations"
       action 0.2 cli command "enable"
       action 1.0 cli command "clear ip nat translation *"
     <#if isCellIntTable[p] != "true">
       event manager applet lanup_40
        event track 40 state up
        action 0.1 syslog msg "LAN UP"
        action 0.2 cli command "enable"
        action 0.3 cli command "conf t"
        <#if herIpAddress?has_content && isPrimaryHeadEndEnable == "true">
         action 0.4 cli command "ip route ${herIpAddress} 255.255.255.255 ${priorityIfNameTable[p]} dhcp"
         <#if backupHerIpAddress?has_content && isSecondaryHeadEndEnable == "true">
           action 0.5 cli command "ip route ${backupHerIpAddress} 255.255.255.255 ${priorityIfNameTable[p]} dhcp"
         </#if>
        </#if>
        action 0.8 cli command "ip route ${nms.herIP} 255.255.255.255 ${priorityIfNameTable[p]} dhcp"
        action 0.9 cli command "end"
       event manager applet landown_40
        event track 40 state down
        action 0.1 syslog msg "LAN DOWN"
        action 0.2 cli command "enable"
        action 0.3 cli command "conf t"
        <#if herIpAddress?has_content && isPrimaryHeadEndEnable == "true">
         action 0.4 cli command "no ip route ${herIpAddress} 255.255.255.255 ${priorityIfNameTable[p]} dhcp"
         <#if backupHerIpAddress?has_content && isSecondaryHeadEndEnable == "true">
           action 0.5 cli command "no ip route ${backupHerIpAddress} 255.255.255.255 ${priorityIfNameTable[p]} dhcp"
         </#if>
        </#if>
        action 0.8 cli command "no ip route ${nms.herIP} 255.255.255.255 ${priorityIfNameTable[p]} dhcp"
        action 0.9 cli command "end"
     </#if>
     <#if isWGBIntTable[p] == "true">
       event manager applet WGB_HEALTH_CHECK
        event track ${p+40} stat down
        action 0.1  track read ${p+40}
        action 0.2  if $_track_state ne "down"
        action 0.3   exit
        action 0.4  end
        action 1    cli command "enable"
        action 2    cli command "ping ${ipslaDestIPaddress[p]} time 1 repeat 3"
        action 3    regexp "(!!)" "$_cli_result" _match
        action 4    if $_regexp_result ne "1"
        action 4.1   syslog priority warnings msg "WGB Test Failed"
        action 4.42   cli command "release dhcp ${wgb_if}"
        action 4.43   cli command "renew dhcp ${wgb_if}"
        action 5    end
     </#if>
     int ${priorityIfNameTable[p]}
       zone-member security INTERNET
       ip nat outside
       no shutdown
     <#if isTunnelEnabledTable[p] == "true" && isPrimaryHeadEndEnable == "true">
       crypto ikev2 client flexvpn ${vpnTunnelIntf}
       source ${p+1} ${priorityIfNameTable[p]} track ${p+40}
       <#if isCellIntTable[p] != "true">
         <#assign suffix = "dhcp">
       <#else>
         <#assign track_num = p + 40>
         <#assign suffix = "track " + track_num>
       </#if>
       <#if herIpAddress?has_content && isPrimaryHeadEndEnable == "true">
         ip route ${herIpAddress} 255.255.255.255 ${priorityIfNameTable[p]} ${suffix} ${p+40}
         <#if backupHerIpAddress?has_content && isSecondaryHeadEndEnable == "true">
           ip route ${backupHerIpAddress} 255.255.255.255 ${priorityIfNameTable[p]} ${suffix} ${p+40}
         </#if>
       </#if>
     </#if>
   </#list>
 </#if>


<#if isWgbEnable == "true">
  route-map RM_WGB_ACL permit 10
    match ip address NAT_ACL
    match interface ${wgb_if}
  !
  ip nat inside source route-map RM_WGB_ACL interface ${wgb_if} overload
</#if>

<#-- Zone based firewall.  Expands on Bootstrap config -->

ip access-list extended eCVD-deny-from-outside

<#assign count = 10>
<#if far.firewallIp??>
<#list far.firewallIp as FW>
  <#if FW['fwType']?has_content>
   <#if FW['fwType'] == "deny">
    <#if FW['fwProtocol'] == "ip" || FW['fwProtocol'] == "icmp">
   ${count} deny ${FW['fwProtocol']} ${FW['fwSrcIp']} ${FW['fwSrcMask']} any
    <#else>
   ${count} deny ${FW['fwProtocol']} ${FW['fwSrcIp']} ${FW['fwSrcMask']} eq ${FW['fwPort']} any
    </#if>
   <#assign count += 10>
   </#if>
  </#if>
 </#list>
</#if>

  ip access-list extended eCVD-permit-from-outside

<#assign count = 10>
<#if far.firewallIp??>
<#list far.firewallIp as FW>
  <#if FW['fwType']?has_content>
   <#if FW['fwType'] == "allow">
    <#if FW['fwProtocol'] == "ip" || FW['fwProtocol'] == "icmp">
   ${count} permit ${FW['fwProtocol']} ${FW['fwSrcIp']} ${FW['fwSrcMask']} any
    <#else>
   ${count} permit ${FW['fwProtocol']} ${FW['fwSrcIp']} ${FW['fwSrcMask']} eq ${FW['fwPort']} any
    </#if>
   <#assign count += 10>
   </#if>
  </#if>
 </#list>
</#if>
!
 class-map type inspect match-any eCVD-deny-list
   match access-group name eCVD-deny-from-outside
!
 class-map type inspect match-any eCVD-permit-list
   match access-group name eCVD-permit-from-outside
!
!
  policy-map type inspect INTERNET2Any
    class type inspect eCVD-permit-list
      inspect
    class type inspect eCVD-deny-list
      drop
!
int ${ether_if}
  zone-member security INTERNET
  !
<#if isFirstCell == "true">
int ${cell_if1}
  zone-member security INTERNET
  !
</#if>
<#if isSecondCell == "true">
int ${cell_if2}
  zone-member security INTERNET
  !
</#if>
!

<#-- QoS config for IOS Classic -->

<#if isQosEnabled == "true">
  <#if qosBandwidth?has_content>
    <#assign QOSbw = qosBandwidth?number>

    <#if qosPolicyTable?has_content>
      class-map match-any CLASS-GOLD
      <#-- traffic class possible values are listed below.  User should be able to place multiple TCs in a class (gold, silver, bronze). -->
      <#list qosPolicyTable as QOS>
        <#if QOS['qosType']?has_content>
          <#if QOS['qosPriority'] == "hi">
            match protocol attribute traffic-class ${QOS['qosType']}
          </#if>
        </#if>
      </#list>
!
      class-map match-any CLASS-SILVER
      <#list qosPolicyTable as QOS>
        <#if QOS['qosType']?has_content>
          <#if QOS['qosPriority'] == "med">
            match protocol attribute traffic-class ${QOS['qosType']}
          </#if>
        </#if>
      </#list>
!
      class-map match-any CLASS-BRONZE
      <#list qosPolicyTable as QOS>
        <#if QOS['qosType']?has_content>
          <#if QOS['qosPriority'] == "low">
            match protocol attribute traffic-class ${QOS['qosType']}
          </#if>
        </#if>
      </#list>
!
      class-map match-any CLASS-SILVER-BRONZE
      <#list qosPolicyTable as QOS>
        <#if QOS['qosType']?has_content>
          <#if QOS['qosPriority'] == "med" || QOS['qosPriority'] == "low">
            match protocol attribute traffic-class ${QOS['qosType']}
          </#if>
        </#if>
      </#list>
!
      policy-map SUB-CLASS-SILVER-BRONZE
       class CLASS-SILVER
       <#-- calculate based on 20% of upstream bandwidth, in kbps -->
       <#assign qosbwkb = QOSbw * 0.20>
       bandwidth ${qosbwkb?int?c}
       class CLASS-BRONZE
        <#-- calculate based on 25% of upstream bandwidth, in kbps -->
        <#assign qosbwkb = QOSbw * 0.25>
        bandwidth ${qosbwkb?int?c}
!
      policy-map SUB-CLASS-GSB
      class CLASS-GOLD
        <#-- kbps.  10% of user entered upstream bandwidth -->
        <#assign qosbwkb = QOSbw * 0.10>
         priority ${qosbwkb?int?c}
      class CLASS-SILVER-BRONZE
       <#-- calculate based on 60% of total upstream in bps -->
       <#assign qbw = QOSbw * 0.60 * 1000>
       shape average ${qbw?int?c}
       <#assign qosbwkb = QOSbw * 0.60>
       bandwidth ${qosbwkb?int?c}
       service-policy SUB-CLASS-SILVER-BRONZE
      class class-default
       fair-queue
       random-detect dscp-based
!
      policy-map CELL_WAN_QOS
       class class-default
        <#assign qbw = QOSbw * 1000>
        shape average ${qbw?int?c}
        service-policy SUB-CLASS-GSB

      <#if isFirstCell?has_content && isFirstCell == "true">
        interface ${cell_if1}
          service-policy output CELL_WAN_QOS
      </#if>

      <#if isSecondCell?has_content && isSecondCell == "true">
        interface ${cell_if2}
          service-policy output CELL_WAN_QOS
      </#if>
    </#if>
  </#if>
</#if>

<#-- --- END OF QoS CONFIG ----------------------------- -->

<#-- Enable GPS  -->
<#if isGpsEnabled?has_content && isGpsEnabled == "true">
gyroscope-reading enable
controller ${cell_if1_contr}
  lte gps mode standalone
  lte gps nmea ip
</#if>
!
<#if config.enableLocationTracking>
  event manager environment _gps_poll_interval ${config.locStreamRate}
  event manager environment _gps_threshold ${config.distThreshold}
  event manager policy fnd-push-gps.tcl type user
  event manager applet GNSS_ENABLE
  event timer cron cron-entry "*/1 * * * *"
  action 010 cli command "enable"
  action 020 cli command "show ${cell_if1} firmware"
  action 030 regexp "Modem is still down, please wait for modem to come up" $_cli_result match
   action 031 if $_regexp_result eq 1
   action 032 syslog msg  "Modem is DOWN, not touching anything and exiting"
   action 033 exit
  action 034 end
  action 035 cli command "show ${cell_if1} gps"
  action 040 foreach line $_cli_result "\r\n"
    action 050 regexp "^GPS Mode Configured:[ ]+(.+)$" $line match _gps_mode
    action 060 if $_regexp_result eq 1
      ! action 070 syslog msg  "GPS MODE $_gps_mode"
      action 080 if $_gps_mode eq "not configured/unknown"
        action 090 syslog msg  "Enabling GPS standalone mode"
        action 100 cli command "conf t"
        action 110 cli command "controller ${cell_if1_contr}"
        action 120 cli command "lte gps mode standalone"
        action 130 cli command "lte gps nmea ip"
        action 160 cli command "end"
        action 170 break
      action 180 end
    action 182 end
    action 185 regexp "^GPS Feature:[ ]+(.+)$" $line match _gps_mode
    action 186 if $_regexp_result eq 1
      action 190 if $_gps_mode eq "Modem reset/power-cycle is needed to enable GPS"
        action 200 syslog msg  "LTE module being power-cycled"
        action 210 cli command "conf t"
        action 211 cli command "controller ${cell_if1_contr}"
        action 212 cli command "lte gps mode standalone"
        action 213 cli command "lte gps nmea ip"
        action 220 cli command "service internal"
        action 230 cli command "do test ${cell_if1} modem-power-cycle"
        action 240 cli command "end"
        action 250 break
      action 260 end
    action 265 end
  action 410 end
</#if>
!
<#if isFirstCell == "true">
interface ${cell_if1}
    ip address negotiated
    dialer in-band
    encapsulation slip
    dialer idle-timeout 0
    dialer-group 1
    dialer string lte
</#if>
!
<#if isSecondCell == "true">
    interface ${cell_if2}
    ip address negotiated
    dialer in-band
    encapsulation slip
    dialer idle-timeout 0
    dialer-group 1
    dialer string lte
</#if>
!
interface Vlan1
    description Subtended network
    ip address ${far.lanIPAddress} ${far.lanNetmask}
    ip nat inside
    ip verify unicast source reachable-via rx
    no shutdown
!
!
<#-- enabling/disabling of ethernet ports -->

<#-- if GigabitEthernet0 is to be used as uplink, this
template will need to be adjusted -->

interface GigabitEthernet0
  description Disabled by eCVD template
	shutdown

interface GigabitEthernet1
<#if isEthernetEnable != "true">
    shutdown
<#else>
  description UPLINK
	no shutdown
</#if>
!
interface GigabitEthernet2
<#if GigEthernet2_enabled != "true">
    shutdown
<#else>
  description SUBTENDED NETWORK
	no shutdown
</#if>
!
interface GigabitEthernet3
<#if GigEthernet3_enabled != "true">
    shutdown
<#else>
  description SUBTENDED NETWORK
	no shutdown
</#if>
!
interface GigabitEthernet4
<#if GigEthernet4_enabled != "true">
    shutdown
<#else>
  description SUBTENDED NETWORK
	no shutdown
</#if>

interface Async0
    no ip address
    encapsulation scada
!
<#-- Enable NAT and routing -->
ip access-list extended NAT_ACL
  ! VLAN 1
  permit ip ${lanNtwk} ${lanWild} any
!
<#if isPrimaryHeadEndEnable == "true">
route-map RM_Tu2 permit 10
     match ip address NAT_ACL
     match interface ${vpnTunnelIntf}
</#if>
!
dialer-list 1 protocol ip permit
!
!
<#if isFirstCell == "true">
route-map RM_WAN_ACL permit 10
    match ip address NAT_ACL
    match interface ${cell_if1}
!
</#if>
route-map RM_WAN_ACL2 permit 10
    match ip address NAT_ACL
    match interface ${ether_if}
!
<#-- ADDED 3 LINES BELOW FOR ADVANCED -->
<#if isSecondCell == "true">
route-map RM_WAN_ACL3 permit 10
    match ip address NAT_ACL
    match interface ${cell_if2}
</#if>
!
ip forward-protocol nd
!
<#if isFirstCell == "true">
ip nat inside source route-map RM_WAN_ACL interface ${cell_if1} overload
</#if>
ip nat inside source route-map RM_WAN_ACL2 interface ${ether_if} overload
<#-- ADDED 1 LINES BELOW FOR ADVANCED -->
<#if isSecondCell == "true">
ip nat inside source route-map RM_WAN_ACL3 interface ${cell_if2} overload
</#if>

<#-- Use default i/f to set PAT -->

<#if far.portForwarding?has_content>
<#list far.portForwarding as PAT>
  <#if PAT['protocol']?has_content>
  <#if EthernetPortPriority == 101>
        ip nat inside source static ${PAT['protocol']} ${PAT['privateIP']} ${PAT['localPort']} interface ${ether_if} ${PAT['publicPort']}
  <#else>
     <#if isFirstCell == "true">
      ip nat inside source static ${PAT['protocol']} ${PAT['privateIP']} ${PAT['localPort']} interface ${cell_if1} ${PAT['publicPort']}
     </#if>
  </#if>
  </#if>
</#list>
</#if>

<#if isFirstCell == "true">
! Remove routes from Bootstrap that we don't want
event manager applet remove-cell0-route-failproof-cli
  event timer countdown time 15
  action 600 cli command "enable"
  action 610 cli command "conf t"
  action 620 cli command "no ip route 0.0.0.0 0.0.0.0 ${cell_if1} 100"
  action 630 cli command "no event manager applet remove-cell0-route-failproof-cli"
  action 640 cli command "exit"
  action 650 cli command "write mem"
</#if>

<#if isPrimaryHeadEndEnable == "true" && herIpAddress?has_content>
  ip route ${herIpAddress}  255.255.255.255 ${ether_if} dhcp
  <#if isSecondaryHeadEndEnable == "true" && backupHerIpAddress?has_content>
    ip route ${backupHerIpAddress} 255.255.255.255 ${ether_if} dhcp
  </#if>
</#if>
!
<#-- User defined static routes with either next hop or egress interface -->
<#if far.staticRoute?has_content>
  <#list far.staticRoute as SR>
    <#if SR['destNetwork']?has_content>
      <#assign dst_intf = "">
      <#switch SR['nextInterface']>
        <#case "ether_if">
          <#assign dst_intf = ether_if!"">
          <#break>
        <#case "cell_if1">
          <#assign dst_intf = cell_if1!"">
          <#break>
        <#case "cell_if2">
          <#assign dst_intf = cell_if2!"">
          <#break>
        <#case "VPN">
          <#assign dst_intf = vpnTunnelIntf!"">
          <#break>
        <#case "WGB">
          <#assign dst_intf = wgb_if!"">
          <#break>
      </#switch>
      <#if dst_intf?has_content>
        ip route ${SR['destNetwork']} ${SR['destNetMask']} ${dst_intf}
      </#if>
    </#if>
  </#list>
</#if>
!
<#if isPrimaryHeadEndEnable == "true">
ip nat inside source route-map RM_Tu2 interface ${vpnTunnelIntf} overload
</#if>
!
ip ssh rsa keypair-name SSHKEY
ip ssh version 2
ip scp server enable
!
ip access-list extended filter-internet
 permit icmp any any echo
 permit icmp any any echo-reply
 permit icmp any any unreachable
 permit icmp any any packet-too-big
 permit icmp any any ttl-exceeded
 permit udp any eq bootps host 255.255.255.255 eq bootpc
<#if isPrimaryHeadEndEnable == "true" && herIpAddress?has_content>
 permit esp host ${herIpAddress} any
  <#if isSecondaryHeadEndEnable == "true" && backupHerIpAddress?has_content>
    permit esp host ${backupHerIpAddress} any
  </#if>
</#if>
!

<#-- ADDED 11 LINES BELOW FOR ADVANCED -->
<#-- OPTIONALLY remove NAT overload config and config and setup routing over FlexVPN S2SVPN -->
<#if isPrimaryHeadEndEnable == "true">
no ip nat inside source route-map RM_Tu2 interface ${vpnTunnelIntf} overload
no route-map RM_Tu2 permit 10

interface ${vpnTunnelIntf}
 no ip nat outside
!
</#if>

ip access-list standard CLOUD
  permit ${lanNtwk} ${lanWild}

<#if isPrimaryHeadEndEnable == "true">
crypto ikev2 authorization policy CVPN
  route set access-list CLOUD
!
</#if>

<#-- ADDED LINES BELOW FOR ADVANCED -->
<#-- Reverse telnet to serial port at TCP port 2050 -->
!
line console 0
  transport output telnet ssh
  databits 8
  parity none
  stopbits 1
  speed 9600

line vty 0 4
    exec-timeout 5 0
    length 0
    transport input ssh

<#-- ADDED LINES BELOW FOR ADVANCED -->
<#-- Netflow -->

<#if isNetflow?has_content && isNetflow == "true" && netflowCollectorIP?has_content>
 flow record defaultStealthWatch
  match ipv4 protocol
  match ipv4 source address
  match ipv4 destination address
  match transport source-port
  match transport destination-port
  match interface input
  match ipv4 tos
  collect interface output
  collect counter bytes long
  collect counter packets
  collect timestamp sys-uptime first
  collect timestamp sys-uptime last

flow exporter export_Gi0_0_0_-63055531
 destination ${netflowCollectorIP}
 source Loopback 1
 transport udp 2055
 template data timeout 60

flow monitor dsw_Gi0_0_0_-63055531
 exporter export_Gi0_0_0_-63055531
 cache timeout active 60
 record defaultStealthWatch
<#-- add logic to use other WAN interfaces -->
interface ${ether_if}
 ip flow monitor dsw_Gi0_0_0_-63055531 input
!
!
</#if>

<#-- ------------------------------------------ -->
<#-- ------------------------------------------ -->
<#-- ------------------------------------------ -->

<#-- generare RSA keys for SSH -->

event manager applet ssh_crypto_key authorization bypass
  event timer watchdog time 30 maxrun 60
  action 1.0 cli command "enable"
  action 2.0 cli command "show ip ssh | include ^SSH"
  action 2.1 regexp "([ED][^ ]+)" "$_cli_result" _result
  action 3.0 if $_result eq Disabled
  action 3.1   syslog msg "EEM:ssh_crypto_key generating new SSHKEY "
  action 3.2   cli command "config t"
  action 3.3   cli command "crypto key generate rsa usage-keys label SSHKEY modulus 2048"
  action 3.4   cli command "end"
  action 3.5   cli command "write mem" pattern "confirm|#"
  action 3.6   regexp "confirm" "$_cli_result"
  action 3.7   if $_regexp_result eq "1"
  action 3.8     cli command "y"
  action 3.9   end
  action 4.0 end
  action 5.1 syslog msg "EEM:ssh_crypto_key hara-kiri "
  action 5.2 cli command "config t"
  action 5.3 cli command "no event manager applet ssh_crypto_key"


<#-- Set APN -->

<#if isFirstCell?has_content && isFirstCell == "true" && APN1?has_content>
  event manager applet change_apn_cell1
  event timer countdown time 10
  action 5 syslog msg "Changing APN Profile"
  action 10 cli command "enable"
  action 15 cli command "${cell_if1} lte profile create 1 ${APN1}" pattern "confirm"
  action 20 cli command "y"
</#if>
!
<#if isSecondCell?has_content && isSecondCell == "true" && APN2?has_content>
  event manager applet change_apn_cell2
  event timer countdown time 10
  action 5 syslog msg "Changing APN Profile for Cellular0/3/0"
  action 10 cli command "enable"
  action 15 cli command "${cell_if2} lte profile create 1 ${APN2}" pattern "confirm"
  action 20 cli command "y"
</#if>
!

<#-- Ignition Power Management -->

<#if ignition?has_content && ignition == "true">
  ignition enable
  ignition off-timer 400
<#else>
  no ignition enable
</#if>

<#if section.wan_wgb?has_content && section.wan_wgb == "true">
event manager applet setAPvlan
  event timer watchdog time 120
  action 1.0 cli command "en"
  action 2.0 cli command "sh cgna profile-state all | i cg-nms-ap-bootstrap"
  action 2.1 string match "*cg-nms-ap-bootstrap*" "$_cli_result"
  action 2.2 set ap_bootstrap_present $_string_result
  action 3.0 cli command "show cgna profile name cg-nms-ap-bootstrap | i disabled"
  action 3.1 string match "*Profile disabled*" "$_cli_result"
  action 3.2 set ap_bootstrap_disabled $_string_result
  action 4.0 cli command "sh cgna profile-state all | i cg-nms-ap-register"
  action 4.1 string match "*cg-nms-ap-register*" "$_cli_result"
  action 4.2 set ap_register_present $_string_result
  action 5.0 if $ap_bootstrap_present eq "1"
  action 5.01 if $ap_bootstrap_disabled eq "0"
  action 5.02 exit
  action 5.03 end
  action 5.1 end
  action 6.0 if $ap_bootstrap_present eq "0"
  action 6.01 if $ap_register_present eq "0"
  action 6.02 exit
  action 6.03 end
  action 6.1 end
  action 7.0 cli command "conf t"
  action 7.1 cli command "int wlan-gi0"
  action 7.2 cli command "switchport trunk native vlan 50"
  action 7.25 cli command "no spanning-tree vlan 50"
  action 7.3 cli command "no event manager applet setAPvlan"
  action 8.0 cli command "exit"
  action 8.1 cli command "write mem"
</#if>

<#-- When Gig1 goes down, Vlan10 will stay up because it is
also used by Wlan0 interface in trunking mode. This script
will clear the DHCP lease when Gig1 goes down, also clearing
the route -->
<#if model == "IR829" && ether_if == "vlan10">
track 110 interface GigabitEthernet1 line-protocol
  delay down 10
event manager applet CLEAR_DHCP
  event track 110 state down
  action 1.0 cli command "enable"
  action 1.1 cli command "release dhcp vlan 10"
  action 1.2 cli command "renew dhcp vlan 10"
</#if>

<#-- -- LOGGING ONLY ------------------------- -->
<#if dumpAllVariables>
  <#assign dumpSubParams = ['far', 'section', 'nms']>
    <#list dumpSubParams as subParm>
    event manager applet ListAll_${subParm}
    <#assign i = 100>
    <#list subParm?eval as key, value>
      <#if value??>
        <#if value?is_string>
          action ${i} cli command "${subParm}.${key} = ${value}"
          <#assign i = i + 1>
        <#elseif value?is_sequence>
          <#assign subi = 0>
          <#list value as val>
            <#list val as subkey, subvalue>
              action ${i} cli command "${subParm}.${key} [${subi}] ${subkey} = ${subvalue}"
              <#assign i = i + 1>
            </#list>
            <#assign subi = subi + 1>
          </#list>
        </#if>
      <#elseif !value??>
        action ${i} cli command "${subParm}.${key} = *null*"
        <#assign i = i + 1>
      </#if>
    </#list>
  </#list>
</#if> <#-- end of dumpAllVariables -->
<#-- END OF LOGGING ONLY --------------------- -->

<#-- EEM to create backup config for 829 recovery, to bypass auto PnP Discovery-->
event manager applet CREATECONF
  event timer countdown time 60 maxrun 90
  action 001 cli command "enable"
  action 002 cli command "dir flash:/managed/bypass-discovery.cfg"
  action 003 regexp "-rw-" "$_cli_result"
  action 004 if $_regexp_result eq "0"
  action 005  syslog msg "*** bypass-discovery.cfg file not found in /managed, will create it ***"
  action 011  file open fd flash:/managed/bypass-discovery.cfg w
  action 012  file puts fd "service timestamps debug datetime msec"
  action 013  file puts fd "service timestamps log datetime msec"
  action 014  file puts fd "no service password-encryption"
  action 015  file puts fd "hostname IR800"
  action 016  file puts fd "no ip http server"
  action 017  file puts fd "no ip http secure-server"
  action 018  file puts fd "ip http client secure-trustpoint CISCO_IDEVID_SUDI"
  action 019  file puts fd "chat-script lte \"\" \"AT!CALL\" TIMEOUT 20 \"OK\""
  action 020  file puts fd "ip domain name cisco.com"
  action 021  file puts fd "ip name-server 8.8.8.8"
  action 022  file puts fd "ip name-server 1.1.1.1"
  action 023  file puts fd "controller Cellular 0"
  action 024  file puts fd " lte sim fast-switchover enable"
  action 025  file puts fd "interface ${ether_if}"
  action 026  file puts fd " ip address dhcp"
  action 027  file puts fd "ip route 0.0.0.0 0.0.0.0 ${ether_if} DHCP"
  action 028  file puts fd "ip route 8.8.8.8 255.255.255.255 ${ether_if} DHCP"
  action 029  file puts fd "ip route 1.1.1.1 255.255.255.255 ${ether_if} DHCP"
  action 030  file puts fd "ip route 0.0.0.0 0.0.0.0 ${cell_if1} 110"
  action 031  file puts fd "ip route 8.8.8.8 255.255.255.255 ${cell_if1} 110"
  action 032  file puts fd "ip route 1.1.1.1 255.255.255.255 ${cell_if1} 110"
  action 040  file puts fd "ipv6 route ::/0 ${ether_if}"
  action 041  file puts fd "ipv6 route ::/0 ${cell_if1} 110"
  action 042  file puts fd "dialer-list 1 protocol ip permit"
  action 043  file puts fd "dialer-list 1 protocol ipv6 permit"
  action 046  file puts fd "interface ${cell_if1}"
  action 047  file puts fd " ip address negotiated"
  action 048  file puts fd " encapsulation slip"
  action 049  file puts fd " ip tcp adjust-mss 1460"
  action 050  file puts fd " dialer in-band"
  action 051  file puts fd " dialer idle-timeout 0"
  action 052  file puts fd " dialer string lte"
  action 053  file puts fd " dialer-group 1"
  action 054  file puts fd " ipv6 address autoconfig"
  action 055  file puts fd "line con 0"
  action 056  file puts fd " exec-timeout 0 0"
  action 057  file puts fd " stopbits 1"
  action 058  file puts fd "line 1 2"
  action 059  file puts fd " stopbits 1"
  action 060  file puts fd "line 3"
  action 070  file puts fd " script dialer lte"
  action 071  file puts fd " no exec"
  action 072  file puts fd " transport preferred none"
  action 073  file puts fd " transport output lat pad telnet rlogin lapb-ta mop udptn v120 ssh"
  action 074  file puts fd "line 8"
  action 075  file puts fd " no exec"
  action 076  file puts fd " transport preferred none"
  action 077  file puts fd " transport output lat pad telnet rlogin lapb-ta mop udptn v120 ssh"
  action 078  file puts fd "line 1/3 1/6"
  action 079  file puts fd " transport preferred none"
  action 080  file puts fd " transport output none"
  action 081  file puts fd " stopbits 1"
  action 082  file puts fd "line vty 0 4"
  action 083  file puts fd " login"
  action 084  file puts fd " transport input none"
  action 085  file puts fd "event manager applet FIND_HELPER_IP"
  action 086  file puts fd "  description \"Find devicehelper.cisco.com IP and insert pnp profile\""
  action 087  file puts fd "  event timer watchdog time 30 maxrun 99"
  action 088  file puts fd "  action 1.0  cli command \"enable\""
  action 089  file puts fd "  action 2.0  cli command \"ping ip devicehelper.cisco.com\" pattern \"#\""
  action 090  file puts fd "  action 3.0  set output \"\$_cli_result\""
  action 100  file puts fd "  action 4.0  regexp \"Echos to.*,\" \"\$output\" IPALINE"
  action 101  file puts fd "  action 5.0  if \$_regexp_result eq 0"
  action 102  file puts fd "  action 5.1    syslog msg \"Modem still NOT up. devicehelper.cisco.com NOT reachable\""
  action 103  file puts fd "  action 6.0  else "
  action 104  file puts fd "  action 6.1    regexp \"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\" \"\$IPALINE\" IPA"
  action 105  file puts fd "  action 6.2    syslog msg \"DEVICEHELPER IP in pnp profile: \$IPA\""
  action 106  file puts fd "  action 6.3    cli command \"config t\""
  action 107  file puts fd "  action 6.4    cli command \"pnp profile pnp_cco_profile\""
  action 108  file puts fd "  action 6.5    cli command \"transport https host \$IPA port 443\""
  action 109  file puts fd "  action 6.6    cli command \"no event manager applet FIND_HELPER_IP\""
  action 110  file puts fd "  action 6.7  end"
  action 111  file puts fd "end"
  action 112  file close fd
  action 113 end
  action 114 cli command "config t"
  action 115 cli command "no event manager applet CREATECONF"

<#-- Recovery Scripts -->
  !

  <#if section.devicesettings_recovery?has_content && section.devicesettings_recovery == "true">
    <#if !far.recoveryTimer?has_content>
      <#assign recoveryTime = 120>
    <#else>
      <#assign recoveryTime = far.recoveryTimer>
    </#if>
    <#assign recoveryTimeIOTD = (recoveryTime?number / 2)?round>
  !
  track 88 interface Tunnel1 line-protocol
  event manager environment outage_total_limit ${recoveryTime}
  event manager environment outage_iotd_limit ${recoveryTimeIOTD}
  event manager environment outage_current 0
  !
  event manager applet CHECK_IOTD_RECOVERY_STATUS
    description "Check if connectivity is still lost"
    event timer watchdog time 60 maxrun 99
    action 1.0  cli command "enable"
    action 2.0  track read 88
    action 3.0  if $_track_state eq "down"
    action 4.0    counter name "current_iotd_outage" op inc value 1
    action 5.0    comment syslog msg "IOTD Connectivity failure. Outage increased to:  $_counter_value_remain"
    action 5.1    cli command "config t"
    action 5.2    cli command "event manager environment outage_current $_counter_value_remain"
    action 6.0  end
  !
  event manager applet RESET_IOTD_RECOVERY_COUNTER
    description "Reset counter when IOTD connectivity is restored."
    event track 88 state up maxrun 99
    action 1.0  cli command "enable"
    action 2.0  syslog msg "Connectivity restored. Clearing GW recovery counter."
    action 3.0  counter name "current_iotd_outage" op set value 0
    action 3.1  cli command "config t"
    action 3.2  cli command "event manager environment outage_current 0"
  !
  event manager applet INITIATE_GW_RECOVERY
    description "Clear running config and register GW with IOTD if WAN connectivity lost > timer set"
    event counter name current_iotd_outage entry-val ${recoveryTimeIOTD} entry-op ge exit-op ge exit-val ${recoveryTime} maxrun 120
    action 1.0  counter name "current_iotd_outage" op nop
    action 2.0  syslog msg "IOTD current outage is: $_counter_value_remain. Checking total outage timer."
    action 2.1  if $_counter_value_remain gt $outage_total_limit
    action 2.2    syslog msg "Both timers expired. Will initiate GW recovery."
    action 2.3    counter name "current_iotd_outage" op set value 0
    action 2.4    cli command "enable"
    action 3.0    cli command "show platform nvram | redirect flash:iotd_recovery.log" pattern "confirm|#"
    action 3.1    cli command ""
    action 3.2    cli command "show platform hypervisor | append flash:iotd_recovery.log" pattern "#"
    action 3.3    cli command "show iox host list detail | append flash:iotd_recovery.log" pattern "#"
    action 3.4    cli command "dir /all /recursive all-filesystems | append flash:iotd_recovery.log" pattern "#"
    action 3.5    cli command "show pnp tech-support | append flash:iotd_recovery.log" pattern "#"
    action 3.6    cli command "show clock detail | append flash:iotd_recovery.log" pattern "#"
    action 3.7    cli command "show tech-support | append flash:iotd_recovery.log" pattern "#"
    action 3.8    cli command "show clock detail | append flash:iotd_recovery.log" pattern "#"
    action 3.9    cli command "show logging | append flash:iotd_recovery.log" pattern "#"
    action 4.0    cli command "dir flash:/managed/bypass-discovery.cfg"
    action 4.1    regexp "-rw-" "$_cli_result"
    action 4.2    if $_regexp_result eq "0"
    action 4.3      syslog msg "*** bypass-discovery.cfg NOT found in flash:/managed, will attempt pnp reset ***"
    action 4.4      cli command "pnpa service reset no-prompt"
    action 4.5      reload
    action 5.0    else
    action 5.1      syslog msg "*** bypass-discovery.cfg FOUND in flash:/managed, performing reset ***"
    action 5.2      cli command "copy flash:/managed/bypass-discovery.cfg startup-config" pattern "startup-config|#"
    action 5.3      cli command ""
    action 5.4      wait 10
    action 5.5      reload
    action 6.0    end
    action 6.1  else
    action 6.2    syslog msg "IOTD not reachable, but total outage limit $outage_total_limit not reached yet."
    action 6.3    break
    action 6.4  end
  !
  <#-- END of Recovery Scripts -->

  </#if>

</#compress>

<#-- End eCVD template -->
