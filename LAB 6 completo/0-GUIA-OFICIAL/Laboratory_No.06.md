## Lab No. 06 - Application Layer Protocols, Base Platform, and Network Layer

## Objective

Install and configure basic software for web servers.

## Tools to be used

-  Computers

-  Internet Access

## Introduction

We are continuing to work on the infrastructure of a company that typically hosts several IT infrastructure services. This infrastructure includes both wired and wireless user workstations, as well as physical and virtualized servers, all interconnected through Layer 2 and Layer 3 switches, wireless devices, and routers that provide Internet access. Additionally, it is common to have cloud infrastructures from which resources are provisioned based on the organization’s needs. Among the servers, you can find web services, DNS, email, databases, storage, and applications, among others. Let’s recall the base configuration we are using:

In this lab, we will focus on server infrastructure.


## Simulations

Conduct the following tests individually or in groups, as instructed by the professor, and document your experience.

## 1. Router Simulation

## [For groups of 1, 2, and 3 students]

-  Open Packet Tracer and create a network following the diagram.

-  Now, to configure it, connect from a console similarly to how you do with switches. (The blue cable is a console cable and connects to the serial port – RS232 of each device).

-  Configure the networks to allow addressing the specified hosts.

Networks:

– Student 01:

*

132.18.0.0/16

*

132.19.0..0/16

*

132.20.0..0/16

*

132.21.0..0/16

– Student 02:

*

72.0.0.0/8

*

73.0.0.0/8

*

74.0.0.0/8


- Student 03:

*

154.126.0.0/16

*

154.127.0.0/16

- \* 154.128.0.0/16

- \* 154.129.0.0/16

For the serial interconnection network, use 20.0.0.0/8.

-  Access each router from the computer by going to the desktop tab and selecting the terminal option. Do not modify the default parameters (this is similar to what we will do going forward with the physical routers using the light blue cable at each workstation in the lab). Manually configure the router, so when prompted with ”Continue with configuration dialog? [yes/no]:”, select n, then enter privileged mode and proceed to configuration mode.

```
Continue with configuration dialog? [yes/no]: n
Press RETURN to get started!
Router >
Router > enable
Router# configure terminal
Router(config )#
```

-  Now configure:

- Name of Router0: Your name.

- Name of Router1: Your surname.

- Message of day: ”For exclusive use by RECO students”.

- Screen synchronization.

- Block external server command lookup.

- Interface descriptions.

- Device passwords:

- \* Privilege mode: Clave E

- \* Consult: Clave C

- \* Remote terminal: Clave T

## Support commands:

- Enter privileged mode and then global configuration mode.

```
Router > enable
Router# configure terminal
```

- Router name.

```
Router(config )# hostname <name >
```

- Screen synchronization and passwords.

```
Router(config )# line console 0
Router(config -line)# logging synchronous
Router(config -line)# passwordd <claveConsola >
Router(config -line)# login
Router(config -line)# exit
Router(config )# line vty 0 15
Router(config -line)# logging synchronous
Router(config -line)# password <claveTerminalRemoto >
Router(config -line)# login
Router(config -line)# exit
```


- Block command lookup on external servers.

Router(config )# no ip domain -lookup

- Interfaces description.

Router(config )# interface <interface n/x> Router(config )# description "xxxxxxxxxx"

- Privileged mode access password.

Router(config )# enable secret <clave > Router(config )# exit

- Check the device configuration.

Router# show running -config

- Save the configuration.

Router# copy running -config startup -config Destination filename [startup -config ]? [enter]

-  Test connectivity between the PCs on the same LAN and to different networks. Which ones work and which ones don’t?

-  Configure the routers with static routes so that all devices on the network can ping each other. Note: On each router, include the routes (exit interface) needed to reach networks that are not directly connected.

-  Using the ICMP traceroute command, try to verify communication between the two computers.

-  Connect the setups using the multiuser option so that all computers on the network are visible, and verify the path that the packets follow. Connect the setups through Router1. In the case of three students, connect one setup like this: between student1 and student2 through Router0, and between student2 and student3 through Router1.

-  Show the operation to your instructor.

## Base Software Installation

Part of the foundational platform of an organization’s IT infrastructure involves web services, which can be hosted within the company’s data center or on a cloud server. These services store the organization’s web pages and are used by various clients. In this lab, we will implement this service.

## 1. Web Service Installation

[For groups of 1, 2, and 3 students]

- a. Install the Apache web server on the virtual machine with the FreeBSD operating system.

- b. Install the Nginx web server on the virtual machine with the Slackware Linux operating system.

- c. Configure the web server that comes with Windows Server.

- d. Create a simple webpage on each server to test that it works.

- e. Configure the web servers to start automatically when the operating system boots.

- f. From another computer, test access to the web servers.

- g. Configure the DNS service so that each web server can be accessed by name.

Note: For groups of 3, additionally configure Nginx on CentOS. Groups with 1 student should skip point 2.


## 2. Hosting Service Configuration

[For groups of 2 and 3 students]

On the machine with the Solaris operating system, configure the virtual host service so that hosting services can be provided to multiple companies. The service should be configured in such a way that three webpages hosted on the same web server can be accessed by name, using the URLs of two different domains.

Create virtual hosts that can be accessed as shown below, all of which will reach the same web server installed on Solaris, but each will direct to different webpages.

-  network.<name student 01>.com.co

-  security.<name student 02>.org.jp

-  systems.<name student 03>.com.cl

Show the results to your professor.

Hint: To perform this configuration, you must

- a. Configure the virtual host service in Apache.

- b. Configure the DNS service so that the server names point to the same IP address. Keep in mind that two of the entries belong to one domain and the other to a different domain, so you will need to configure this from the primary DNS servers of each domain.

Note: Groups of 3 must configure the same domains mentioned in this section on the Nginx server installed on Slackware.

## 3. On-Premise Web Application

[For groups of 1, 2, and 3 students]

Using the web service server, write a web application to be deployed using Apache. This application should display a webpage that functions as a basic grade calculator for courses in the School. It must request the student’s name and the final grades for each third of the semester and calculate the final semester grade (30%, 30%, and 40%). Configure it dynamically to interpret PHP code. Additionally, it must save these records in the relational database created on the previous laboratory (e.g., PostgreSQL).
