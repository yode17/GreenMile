 GreenMile

Carbon Offset Tracking for Logistics Companies on Stacks Blockchain

License: MIT(https://img.shields.io/badge/LicenseMITyellow.svg)(https://opensource.org/licenses/MIT)
Stacks(https://img.shields.io/badge/Built_onStacksblue)(https://stacks.co/)
Clarity(https://img.shields.io/badge/LanguageClaritypurple)(https://claritylang.org/)

GreenMile is a blockchainbased carbon offset tracking system designed specifically for logistics companies. Built on the Stacks blockchain using Clarity smart contracts, it enables transparent tracking of fuel consumption, automatic carbon emission calculations, and seamless carbon credit purchasing to achieve netzero logistics operations.

 🌱 Features

 Company Registration: Simple onboarding process for logistics companies
 Route Tracking: Record distance traveled and fuel consumption for each route
 Automatic Emission Calculation: Realtime CO₂ emission calculations using industrystandard factors
 Carbon Credit Trading: Purchase verified carbon credits using STX tokens
 AutoOffset Functionality: Automatically purchase credits to offset accumulated emissions
 Comprehensive Analytics: Track companyspecific and global carbon footprint metrics
 Transparent Reporting: All data stored immutably onchain for audit purposes

 🚀 Quick Start

 Prerequisites

 Stacks Wallet(https://www.hiro.so/wallet) or compatible wallet
 STX tokens for transaction fees and carbon credit purchases
 Basic understanding of Clarity smart contracts

 Deployment

1. Clone this repository:
bash
git clone https://github.com/yourusername/GreenMile.git
cd GreenMile


2. Deploy the contract using Clarinet or your preferred deployment method:
bash
clarinet deploy testnet


3. Note the contract address for interaction with frontend applications

 Usage Examples

 Register Your Company
clarity
(contractcall? .greenmile registercompany "EcoLogistics Inc")


 Record a Route
clarity
 Record a 500km route consuming 150 liters of fuel
(contractcall? .greenmile recordroute u500 u150)


 Purchase Carbon Credits
clarity
 Purchase 100 carbon credits
(contractcall? .greenmile purchasecarboncredits u100)


 AutoOffset All Emissions
clarity
(contractcall? .greenmile autooffsetemissions)


 📊 Contract Architecture

 Core Components

 Component  Description 

 Company Registration  Stores company details and cumulative statistics 
 Route Recording  Tracks individual routes with fuel consumption and emissions 
 Carbon Credit System  Manages credit purchases and offset calculations 
 Analytics Engine  Provides realtime carbon footprint insights 

 Key Constants

 Carbon Factor: 2.64 kg CO₂ per liter of fuel (industry standard)
 Credit Conversion: 1 carbon credit = 1,000 kg CO₂
 Maximum Limits: Builtin validation for route distance (100,000 km) and fuel consumption (50,000 L)

 Data Structures

clarity
 Company Profile
{
  name: (stringascii 50),
  totalfuel: uint,
  totalemissions: uint,
  totaloffsets: uint,
  stxbalance: uint,
  registeredat: uint
}

 Route Record
{
  company: principal,
  distance: uint,
  fuelconsumed: uint,
  emissions: uint,
  timestamp: uint
}


 🔧 API Reference

 Public Functions

 Registration
 registercompany(name)  Register a new logistics company
 Returns: (ok true) on success

 Route Management
 recordroute(distance, fuelconsumed)  Log a new route
 Returns: (ok routeid) with unique route identifier

 Carbon Offsetting
 purchasecarboncredits(credits)  Buy carbon credits with STX
 autooffsetemissions()  Automatically purchase credits for netzero status
 Returns: (ok purchaseid) for successful transactions

 Administration
 setcarbonprice(newprice)  Update carbon credit pricing (owner only)

 ReadOnly Functions

 Data Retrieval
 getcompany(company)  Retrieve company profile
 getroute(routeid)  Get specific route details
 getpurchase(purchaseid)  View carbon credit purchase history

 Analytics
 getcarbonfootprint(company)  Calculate net emissions for a company
 getglobalstats()  View platformwide statistics
 calculateoffsetcost(company)  Estimate cost for full carbon neutrality

 🌍 Environmental Impact

GreenMile promotes environmental responsibility in the logistics industry by:

 Transparency: All emissions data publicly verifiable on blockchain
 Accountability: Immutable records prevent greenwashing
 Incentivization: Easy carbon offsetting encourages sustainable practices
 Standardization: Consistent emission calculation methodology across companies

 🛣️ Roadmap

   Q2 2025: Integration with IoT devices for automatic fuel tracking
   Q3 2025: Support for different fuel types and vehicle classes
   Q4 2025: Carbon credit marketplace with price discovery
   2026: Multichain deployment and crosschain credit transfers
   Future: AIpowered route optimization for emission reduction

 🤝 Contributing

We welcome contributions from developers, logistics professionals, and environmental enthusiasts

 Development Setup

1. Install Clarinet(https://docs.hiro.so/clarinet/gettingstarted):
bash
curl L https://github.com/hirosystems/clarinet/releases/download/v2.0.0/clarinetlinuxx64.tar.gz  tar xz


2. Run tests:
bash
clarinet test


3. Check contract syntax:
bash
clarinet check


 Contribution Guidelines

 Fork the repository and create a feature branch
 Write comprehensive tests for new functionality
 Follow Clarity best practices and code style
 Update documentation for any API changes
 Submit a pull request with detailed description

 Code of Conduct

This project adheres to the Contributor Covenant(https://www.contributorcovenant.org/). Please read our Code of Conduct(CODE_OF_CONDUCT.md) before contributing.

 📄 License

This project is licensed under the MIT License  see the LICENSE(LICENSE) file for details.


MIT License

Copyright (c) 2025 GreenMile Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.