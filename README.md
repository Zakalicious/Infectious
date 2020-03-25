# Infectious
Epidemic modeling using SpriteKit

## Screenshots
![](https://github.com/Zakalicious/Infectious/blob/master/infScreenShot.png)

## Motivation
Inspired by this brilliant [data visualisation](https://www.washingtonpost.com/graphics/2020/world/corona-simulator/). 

[SIR models](https://simple.wikipedia.org/wiki/SIR_model) have been used to describe Ebola, flu and other infectious diseases outbreaks. Instead of partial differential equations a 2D game engine (SpriteKit) is used in this project to simulate the effects of mobility and other parameters on disease outcome.

A simulation starts with a population of susceptible (S) members. After a while a member becomes infected (I). An infected member can recover (R), or die (D). Infection can occur when (I) comes in contact with (S). (R) is immune to new infection. Frequency of infection is obviously dependent on mobility. No mobility (quarantine) -> no infection.

The game engine takes care of graphics and collision detection. The model is easily modified.

## Requirements
Xcode 11.3.1, macOS 10.14

[Charts framework](https://github.com/danielgindi/Charts) (optional, not included). Just delete/replace references to the framework if data charts are of no interest.
 
