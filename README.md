# tanium-powershell

Tanium is a really great tool for keeping your systems up to date, and even though I usually don't like third party tools when the commonly prescribed method is first party (like the ole standby, SCCM), if you're slotting into a situation that already has a tool like Tanium, best to make the most use of the tools you have. Love the one you're with, as they say. 

This script fills in the gaps left by the Tanium documentation and example code. Whenever a system says "You can query our system using natural language!" that typically means that you have to learn how the system wants to be asked, and Tanium is no exception. I'd recommend limiting your scope and really nailing down your question before automating the process using this script. 

Additionally, there is a way to tokenize your login, and that is probably the best thing you could do. Plain-text passwords are usually a really bad idea.

## Pre-Requisites

The Tanium powershell module that I used for this script is included here, in its entirety, and referenced in a relative way. 

## Usage

See the comments for actual script setup, but generally, I'd use a scheduled task to run this as a Service Account that has been granted access to whatever machines you want it to have access to, inside Tanium. This script, in the example, asks Tanium to give us back all servers that have been up for more than 33 days. It doesn't exactly do that, it just doesn't put the days up (it puts [no results]), so that is handled in here too.

First, the script clears out the results directory. Set this up carefully, we just nuke and pave. Next, it initiates a web session with the tanium server, and asks the question, and puts all the results in an array. After that, it filters out all the [no results] results from '_Uptime (integer)'. You can change this if you want to filter out some or none of the results. After that, the entire data set is exported to Excel with Filter and fit turned on and named for the date. Next, the results are carved up and reports are generated for each of the sites that are listed in "AD Query - Computer Site" and made into their own excel sheets. Next, the results folder is checked for empty reports, which are then deleted. 



