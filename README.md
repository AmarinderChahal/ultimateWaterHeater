# The Ultimate Water Heater

February 2018

## Authors

This is the TreeHacks 2018 project created by Amarinder Chahal and Matthew Chan.

## About

Drawing inspiration from a diverse set of real-world information, we designed a system with the goal of efficiently utilizing only electricity to heat and pre-heat water as a means to drastically save energy, eliminate the use of natural gases, enhance the standard of living, and preserve water as a vital natural resource.

Through the accruement of numerous API's and the help of countless wonderful people, we successfully created a functional prototype of a more optimal water heater, giving a low-cost, easy-to-install device that works in many different situations. We also empower the user to control their device and reap benefits from their otherwise annoying electricity bill. But most importantly, our water heater will prove essential to saving many regions of the world from unpredictable water and energy crises, pushing humanity to an inevitably greener future.

Some key features we have:

- 90% energy efficiency
- An average rate of roughly 10 kW/hr of energy consumption
- Analysis of real-time and predictive ISO data of California power grids for optimal energy expenditure
- Clean and easily understood UI for typical household users
- Incorporation of the Internet of Things for convenience of use and versatility of application
- Saving, on average, 5 gallons per shower, or over **__100 million gallons of water daily__**, in CA alone. ***
- Cheap cost of installation and immediate returns on investment

## Inspiration

By observing the RhoAI data dump of 2015 Californian home appliance uses through the use of R scripts, it becomes clear that water-heating is not only inefficient but also performed in an outdated manner. Analyzing several prominent trends drew important conclusions: many water heaters become large consumers of gasses and yet are frequently neglected, most likely due to the trouble in attaining successful installations and repairs. 

So we set our eyes on a safe, cheap, and easily accessed water heater with the goal of efficiency and environmental friendliness. In examining the inductive heating process replacing old stovetops with modern ones, we found the answer. It accounted for every flaw the data decried regarding water-heaters, and would eventually prove to be even better.

## How It Works

Our project essentially operates in several core parts running simulataneously:

- Arduino (101)
- Heating Mechanism
- Mobile Device Bluetooth User Interface
- Servers connecting to the IoT (and servicing via Alexa)
    Repeat all processes simultaneously

The Arduino 101 is the controller of the system. It relays information to and from the heating system and the mobile device over Bluetooth. It responds to fluctuations in the system. It guides the power to the heating system. It receives inputs via the Internet of Things and Alexa to handle voice commands (through the "shower" application). It acts as the peripheral in the Bluetooth connection with the mobile device. Note that neither the Bluetooth connection nor the online servers and webhooks are necessary for the heating system to operate at full capacity.

The heating mechanism consists of a device capable of heating an internal metal through electromagnetic waves. It is controlled by the current (which, in turn, is manipulated by the Arduino) directed through the breadboard and a series of resistors and capacitors. Designing the heating device involed heavy use of applied mathematics and a deeper understanding of the physics behind inductor interference and eddy currents. The calculations were quite messy but mandatorily accurate for performance reasons--Wolfram Mathematica provided inhumane assistance here. ;) 

The mobile device grants the average consumer a means of making the most out of our water heater and allows the user to make informed decisions at an abstract level, taking away from the complexity of energy analysis and power grid supply and demand. It acts as the central connection for Bluetooth to the Arduino 101. The device harbors a vast range of information condensed in an effective and aesthetically pleasing UI. It also analyzes the current and future projections of energy consumption via the data provided by California ISO to most optimally time the heating process at the swipe of a finger.

The Internet of Things provides even more versatility to the convenience of the application in Smart Homes and with other smart devices. The implementation of Alexa encourages the water heater as a front-leader in an evolutionary revolution for the modern age.

## Built With:

(In no particular order of importance...)

- RhoAI
- R
- Balsamiq
- C++ (Arduino 101)
- Node.js
- Tears
- HTML
- Alexa API
- Swift, Xcode
- BLE
- Buckets and Water
- Java
- RXTX (Serial Communication Library)
- Mathematica
- MatLab (assistance)
- Red Bull, Soylent
- Tetrix (for support)
- Home Depot
- Electronics Express
- Breadboard, resistors, capacitors, jumper cables
- Arduino Digital Temperature Sensor (DS18B20)
- Electric Tape, Duct Tape
- Funnel, for testing
- Excel
- Javascript
- jQuery
- Intense Sleep Deprivation
- The wonderful support of the people around us, and TreeHacks as a whole. Thank you all!

*** According to the Washington Post: https://www.washingtonpost.com/news/energy-environment/wp/2015/03/04/your-shower-is-wasting-huge-amounts-of-energy-and-water-heres-what-to-do-about-it/?utm_term=.03b3f2a8b8a2

Special thanks to our awesome friends Michelle and Darren for providing moral support in person!
