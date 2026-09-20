//
//  Model_data.swift
//  GoGreen
//
//  Created by Aakash Singh Ranswal on 21/02/26.
//

let sdgs: [SDG] = [

    SDG(number: 1, title: "No Poverty", tagline: "End poverty in all its forms everywhere",
        description: "No Poverty is about ending extreme poverty and ensuring that everyone has basic needs like food, shelter, healthcare, and education. It focuses on helping people live a life of dignity and security.",
        colorHex: "#E5243B", imageName: "sdg1_bg", symbolName: "house.fill", sectionIDs: ["1"]),

    SDG(number: 2, title: "Zero Hunger", tagline: "End hunger, achieve food security and improved nutrition and promote sustainable agriculture",
        description: "Zero Hunger is about ending hunger and making sure everyone has enough nutritious food. It also promotes sustainable farming so food production can continue without harming the planet.",
        colorHex: "#DDA63A", imageName: "sdg2_bg", symbolName: "leaf.fill", sectionIDs: ["2"]),

    SDG(number: 3, title: "Good Health and Well-being", tagline: "Ensure healthy lives and promote well-being for all at all ages",
        description: "Good Health and Well-being focuses on ensuring healthy lives for everyone. It aims to reduce diseases, improve healthcare access, and promote mental and physical well-being for people of all ages.",
        colorHex: "#4C9F38", imageName: "sdg3_bg", symbolName: "heart.fill", sectionIDs: ["3"]),

    SDG(number: 4, title: "Quality Education", tagline: "Ensure inclusive and equitable quality education and promote lifelong learning opportunities for all",
        description: "Quality Education is about providing quality education for all children and adults. It promotes equal learning opportunities so everyone can develop skills and build a better future.",
        colorHex: "#C5192D", imageName: "sdg4_bg", symbolName: "book.fill", sectionIDs: ["4"]),

    SDG(number: 5, title: "Gender Equality", tagline: "Achieve gender equality and empower all women and girls",
        description: "Gender Equality aims to ensure equal rights and opportunities for women and girls. It focuses on ending discrimination, violence, and inequality in all areas of life.",
        colorHex: "#FF3A21", imageName: "sdg5_bg", symbolName: "person.2.fill", sectionIDs: ["5"]),

    SDG(number: 6, title: "Clean Water and Sanitation", tagline: "Ensure availability and sustainable management of water and sanitation for all",
        description: "Clean Water and Sanitation ensures that everyone has access to clean drinking water and proper sanitation. It also promotes sustainable water management to protect this essential resource.",
        colorHex: "#26BDE2", imageName: "sdg6_bg", symbolName: "drop.fill", sectionIDs: ["6"]),

    SDG(number: 7, title: "Affordable and Clean Energy", tagline: "Ensure access to affordable, reliable, sustainable and modern energy for all",
        description: "Affordable and Clean Energy promotes access to affordable and clean energy for everyone. It supports renewable energy sources to reduce pollution and protect the environment.",
        colorHex: "#FCC30B", imageName: "sdg7_bg", symbolName: "bolt.fill", sectionIDs: ["7"]),

    SDG(number: 8, title: "Decent Work and Economic Growth", tagline: "Promote sustained, inclusive and sustainable economic growth, full and productive employment and decent work for all",
        description: "Decent Work and Economic Growth focuses on creating good job opportunities and promoting economic growth that benefits everyone. It encourages safe working conditions and fair wages.",
        colorHex: "#A21942", imageName: "sdg8_bg", symbolName: "chart.line.uptrend.xyaxis", sectionIDs: ["8"]),

    SDG(number: 9, title: "Industry, Innovation and Infrastructure", tagline: "Build resilient infrastructure, promote inclusive and sustainable industrialization and foster innovation",
        description: "Industry, Innovation and Infrastructure encourages innovation, modern infrastructure, and sustainable industries. It supports technology and development that help improve people’s lives.",
        colorHex: "#FD6925", imageName: "sdg9_bg", symbolName: "gearshape.fill", sectionIDs: ["9"]),

    SDG(number: 10, title: "Reduced Inequalities", tagline: "Reduce inequality within and among countries",
        description: "Reduced Inequalities aims to reduce inequality by ensuring equal opportunities for everyone, regardless of income, gender, disability, or background.",
        colorHex: "#DD1367", imageName: "sdg10_bg", symbolName: "arrow.left.and.right", sectionIDs: ["10"]),

    SDG(number: 11, title: "Sustainable Cities and Communities", tagline: "Make cities and human settlements inclusive, safe, resilient and sustainable",
        description: "Sustainable Cities and Communities focuses on making cities safe, clean, and sustainable. It promotes better housing, public transport, and disaster resilience for communities.",
        colorHex: "#FD9D24", imageName: "sdg11_bg", symbolName: "building.2.fill", sectionIDs: ["11"]),

    SDG(number: 12, title: "Responsible Consumption and Production", tagline: "Ensure sustainable consumption and production patterns",
        description: "Responsible Consumption and Production promotes responsible use of resources. It encourages reducing waste, recycling, and producing goods in ways that protect the environment.",
        colorHex: "#BF8B2E", imageName: "sdg12_bg", symbolName: "arrow.triangle.2.circlepath", sectionIDs: ["12"]),

    SDG(number: 13, title: "Climate Action", tagline: "Take urgent action to combat climate change and its impacts",
        description: "Climate Action calls for urgent action against climate change. It supports reducing carbon emissions and preparing communities for climate-related disasters.",
        colorHex: "#3F7E44", imageName: "sdg13_bg", symbolName: "globe.americas.fill", sectionIDs: ["13"]),

    SDG(number: 14, title: "Life Below Water", tagline: "Conserve and sustainably use the oceans, seas and marine resources for sustainable development",
        description: "Life Below Water focuses on protecting oceans and marine life. It aims to reduce pollution, prevent overfishing, and conserve aquatic ecosystems.",
        colorHex: "#0A97D9", imageName: "sdg14_bg", symbolName: "drop.triangle.fill", sectionIDs: ["14"]),

    SDG(number: 15, title: "Life on Land", tagline: "Protect, restore and promote sustainable use of terrestrial ecosystems",
        description: "Life on Land promotes protecting forests, wildlife, and land ecosystems. It works to stop deforestation and biodiversity loss.",
        colorHex: "#56C02B", imageName: "sdg15_bg", symbolName: "leaf.arrow.circlepath", sectionIDs: ["15"]),

    SDG(number: 16, title: "Peace, Justice and Strong Institutions", tagline: "Promote peaceful and inclusive societies, ensure justice for all, and build accountable institutions",
        description: "Peace, Justice and Strong Institutions supports peaceful societies, fair laws, and strong institutions. It promotes justice, human rights, and reduced corruption.",
        colorHex: "#00689D", imageName: "sdg16_bg", symbolName: "building.columns.fill", sectionIDs: ["16"]),

    SDG(number: 17, title: "Partnerships for the Goals", tagline: "Strengthen the means of implementation and revitalize the Global Partnership for Sustainable Development",
        description: "Partnerships for the Goals is about global partnerships. It encourages countries, organizations, and communities to work together to achieve all the SDGs.",
        colorHex: "#19486A", imageName: "sdg17_bg", symbolName: "person.3.fill", sectionIDs: ["17"])
]

let sectionsBySDG: [String: [SDGSection]] = [

"1": [
    SDGSection(
        title: "Why This Goal Matters",
        summary: "Poverty is more than a lack of income — it limits dreams, opportunities, and dignity. Ending poverty means ensuring every person has the chance to live safely and build a better future.",
        keyPoints: [
            "Millions still struggle to meet basic needs",
            "Poverty restricts access to education and healthcare",
            "Inclusive growth creates stronger societies"
        ]
    ),
    SDGSection(
        title: "Challenges",
        summary: "Many families remain trapped in cycles of hardship due to inequality, limited resources, and unexpected crises.",
        keyPoints: [
            "Unstable employment opportunities",
            "Weak social support systems",
            "Economic shocks and natural disasters"
        ]
    ),
    SDGSection(
        title: "How You Can Help",
        summary: "Even small actions can create meaningful change and open doors for others.",
        keyPoints: [
            "Support local and ethical initiatives",
            "Volunteer or donate to community programs",
            "Advocate for inclusive opportunities"
        ]
    ),
    SDGSection(
        title: "Impact",
        summary: "Reducing poverty strengthens communities, improves well-being, and creates a more equitable world for everyone.",
        keyPoints: [
            "Better living standards",
            "Stronger economies",
            "Greater social resilience"
        ]
    )
],

"2": [
    SDGSection(
        title: "Why This Goal Matters",
        summary: "Food is a basic human need. Ending hunger ensures that everyone can grow, learn, and thrive without the burden of food insecurity.",
        keyPoints: [
            "Millions face daily hunger",
            "Nutrition is critical for healthy development",
            "Food security supports stability"
        ]
    ),
    SDGSection(
        title: "Challenges",
        summary: "Climate change, conflict, and inequality continue to disrupt food systems and access to nutrition.",
        keyPoints: [
            "Rising food prices",
            "Crop failures and shortages",
            "Unequal food distribution"
        ]
    ),
    SDGSection(
        title: "How You Can Help",
        summary: "Thoughtful choices can reduce waste and support sustainable food systems.",
        keyPoints: [
            "Reduce food waste at home",
            "Support sustainable farming",
            "Contribute to food relief programs"
        ]
    ),
    SDGSection(
        title: "Impact",
        summary: "Ending hunger improves health, boosts productivity, and creates stronger communities.",
        keyPoints: [
            "Improved nutrition",
            "Healthier populations",
            "Greater economic stability"
        ]
    )
],

"3": [
    SDGSection(
        title: "Why This Goal Matters",
        summary: "Good health allows people to live fulfilling lives and contribute positively to their communities.",
        keyPoints: [
            "Healthcare saves lives",
            "Mental health matters as much as physical health",
            "Healthy societies drive progress"
        ]
    ),
    SDGSection(
        title: "Challenges",
        summary: "Health systems face growing pressure from inequality, disease outbreaks, and limited access to care.",
        keyPoints: [
            "Healthcare disparities",
            "Resource shortages",
            "Emerging health risks"
        ]
    ),
    SDGSection(
        title: "How You Can Help",
        summary: "Promoting healthy habits and awareness supports collective well-being.",
        keyPoints: [
            "Encourage preventive care",
            "Support health initiatives",
            "Prioritize mental wellness"
        ]
    ),
    SDGSection(
        title: "Impact",
        summary: "Healthier communities are more resilient, productive, and prepared for the future.",
        keyPoints: [
            "Longer life expectancy",
            "Reduced disease burden",
            "Improved quality of life"
        ]
    )
],

"4": [
    SDGSection(
        title: "Why This Goal Matters",
        summary: "Education unlocks potential and empowers people to shape their futures with confidence and knowledge.",
        keyPoints: [
            "Education reduces inequality",
            "Creates opportunities for growth",
            "Drives innovation and progress"
        ]
    ),
    SDGSection(
        title: "Challenges",
        summary: "Barriers such as poverty, lack of resources, and unequal access prevent many from receiving quality education.",
        keyPoints: [
            "School dropout rates",
            "Digital divide",
            "Insufficient learning resources"
        ]
    ),
    SDGSection(
        title: "How You Can Help",
        summary: "Supporting learning initiatives helps build a more informed and equitable society.",
        keyPoints: [
            "Volunteer as a mentor",
            "Promote inclusive education",
            "Support educational programs"
        ]
    ),
    SDGSection(
        title: "Impact",
        summary: "Education strengthens communities and creates pathways to a brighter future.",
        keyPoints: [
            "Empowered individuals",
            "Economic growth",
            "Social advancement"
        ]
    )
],

"5": [
    SDGSection(
        title: "Why This Goal Matters",
        summary: "Gender equality ensures that everyone has the freedom, respect, and opportunity to reach their full potential.",
        keyPoints: [
            "Equality strengthens societies",
            "Empowered women drive development",
            "Fairness benefits everyone"
        ]
    ),
    SDGSection(
        title: "Challenges",
        summary: "Deep-rooted biases and systemic barriers continue to limit opportunities for many women and girls.",
        keyPoints: [
            "Gender discrimination",
            "Unequal pay and opportunities",
            "Underrepresentation in leadership"
        ]
    ),
    SDGSection(
        title: "How You Can Help",
        summary: "Promoting respect and fairness creates meaningful change in everyday life.",
        keyPoints: [
            "Challenge stereotypes",
            "Support equal opportunities",
            "Advocate for inclusion"
        ]
    ),
    SDGSection(
        title: "Impact",
        summary: "Equality leads to healthier communities, stronger economies, and lasting progress.",
        keyPoints: [
            "Greater social justice",
            "Improved economic outcomes",
            "Inclusive development"
        ]
    )
],

"6": [
    SDGSection(
        title: "Why This Goal Matters",
        summary: "Access to clean water and sanitation is essential for health, dignity, and sustainable living.",
        keyPoints: [
            "Safe water prevents disease",
            "Sanitation improves quality of life",
            "Water is a fundamental human right"
        ]
    ),
    SDGSection(
        title: "Challenges",
        summary: "Water scarcity, pollution, and inadequate infrastructure threaten access for millions worldwide.",
        keyPoints: [
            "Unsafe drinking water sources",
            "Poor sanitation systems",
            "Climate-related water stress"
        ]
    ),
    SDGSection(
        title: "How You Can Help",
        summary: "Simple actions can protect water resources and support sustainability.",
        keyPoints: [
            "Conserve water daily",
            "Reduce pollution and waste",
            "Support clean water initiatives"
        ]
    ),
    SDGSection(
        title: "Impact",
        summary: "Improved water access leads to healthier communities and a more sustainable environment.",
        keyPoints: [
            "Reduced illness",
            "Improved livelihoods",
            "Environmental protection"
        ]
    )
],
"7": [
    SDGSection(
        title: "Why This Goal Matters",
        summary: "Clean and reliable energy powers progress, improves quality of life, and helps protect our planet for future generations.",
        keyPoints: [
            "Energy access supports education and healthcare",
            "Renewable energy reduces environmental impact",
            "Sustainable power drives innovation"
        ]
    ),
    SDGSection(
        title: "Challenges",
        summary: "Many communities still rely on polluting energy sources or lack reliable electricity altogether.",
        keyPoints: [
            "Dependence on fossil fuels",
            "Energy inequality across regions",
            "High costs of infrastructure transition"
        ]
    ),
    SDGSection(
        title: "How You Can Help",
        summary: "Making conscious energy choices can support a cleaner and more sustainable future.",
        keyPoints: [
            "Reduce energy consumption",
            "Support renewable energy solutions",
            "Use energy-efficient appliances"
        ]
    ),
    SDGSection(
        title: "Impact",
        summary: "Clean energy reduces emissions, improves living standards, and supports long-term sustainability.",
        keyPoints: [
            "Lower carbon footprint",
            "Energy security",
            "Healthier environments"
        ]
    )
],

"8": [
    SDGSection(
        title: "Why This Goal Matters",
        summary: "Decent work empowers individuals, supports families, and fuels economic growth that benefits society as a whole.",
        keyPoints: [
            "Fair jobs reduce poverty",
            "Safe workplaces protect well-being",
            "Inclusive growth builds resilience"
        ]
    ),
    SDGSection(
        title: "Challenges",
        summary: "Unemployment, job insecurity, and unsafe working conditions continue to affect millions worldwide.",
        keyPoints: [
            "Youth unemployment",
            "Informal labor markets",
            "Economic instability"
        ]
    ),
    SDGSection(
        title: "How You Can Help",
        summary: "Supporting ethical practices and inclusive opportunities contributes to stronger economies.",
        keyPoints: [
            "Support fair and responsible businesses",
            "Encourage skill development",
            "Promote entrepreneurship"
        ]
    ),
    SDGSection(
        title: "Impact",
        summary: "Sustainable economic growth creates opportunities, reduces inequality, and improves quality of life.",
        keyPoints: [
            "Job creation",
            "Innovation and productivity",
            "Community prosperity"
        ]
    )
],

"9": [
    SDGSection(
        title: "Why This Goal Matters",
        summary: "Innovation and resilient infrastructure connect communities, enable progress, and drive sustainable development.",
        keyPoints: [
            "Infrastructure supports economic growth",
            "Innovation solves global challenges",
            "Connectivity improves opportunities"
        ]
    ),
    SDGSection(
        title: "Challenges",
        summary: "Gaps in technology, funding, and infrastructure limit progress in many regions.",
        keyPoints: [
            "Digital divide",
            "Limited investment in innovation",
            "Aging or inadequate infrastructure"
        ]
    ),
    SDGSection(
        title: "How You Can Help",
        summary: "Encouraging creativity and supporting sustainable solutions can help build a better future.",
        keyPoints: [
            "Support innovation initiatives",
            "Promote digital inclusion",
            "Advocate sustainable development"
        ]
    ),
    SDGSection(
        title: "Impact",
        summary: "Strong infrastructure and innovation improve livelihoods and strengthen economies.",
        keyPoints: [
            "Better services and connectivity",
            "Economic resilience",
            "Technological progress"
        ]
    )
],

"10": [
    SDGSection(
        title: "Why This Goal Matters",
        summary: "Reducing inequalities ensures that everyone has a fair chance to succeed and contribute meaningfully to society.",
        keyPoints: [
            "Equality promotes social harmony",
            "Inclusion strengthens communities",
            "Fair opportunities benefit everyone"
        ]
    ),
    SDGSection(
        title: "Challenges",
        summary: "Social, economic, and systemic barriers continue to limit access to opportunities for many groups.",
        keyPoints: [
            "Income disparities",
            "Discrimination and exclusion",
            "Unequal access to resources"
        ]
    ),
    SDGSection(
        title: "How You Can Help",
        summary: "Supporting inclusion and respecting diversity can create lasting positive change.",
        keyPoints: [
            "Stand against discrimination",
            "Support inclusive initiatives",
            "Promote fairness in daily life"
        ]
    ),
    SDGSection(
        title: "Impact",
        summary: "More equal societies are more stable, peaceful, and prosperous.",
        keyPoints: [
            "Stronger social cohesion",
            "Greater opportunities",
            "Improved well-being"
        ]
    )
],

"11": [
    SDGSection(
        title: "Why This Goal Matters",
        summary: "Sustainable cities create safe, inclusive, and vibrant spaces where people can live, work, and thrive.",
        keyPoints: [
            "Urban planning shapes quality of life",
            "Sustainable transport reduces pollution",
            "Inclusive cities support communities"
        ]
    ),
    SDGSection(
        title: "Challenges",
        summary: "Rapid urbanization brings challenges such as congestion, pollution, and housing shortages.",
        keyPoints: [
            "Air pollution and waste",
            "Traffic congestion",
            "Limited affordable housing"
        ]
    ),
    SDGSection(
        title: "How You Can Help",
        summary: "Everyday choices can contribute to more sustainable and livable cities.",
        keyPoints: [
            "Use public or eco-friendly transport",
            "Reduce waste and recycle",
            "Support community initiatives"
        ]
    ),
    SDGSection(
        title: "Impact",
        summary: "Sustainable cities improve health, resilience, and overall quality of life.",
        keyPoints: [
            "Cleaner environments",
            "Stronger communities",
            "Better urban living"
        ]
    )
],

"12": [
    SDGSection(
        title: "Why This Goal Matters",
        summary: "Responsible consumption protects natural resources and ensures that future generations can thrive.",
        keyPoints: [
            "Reducing waste conserves resources",
            "Sustainable choices protect ecosystems",
            "Mindful consumption supports balance"
        ]
    ),
    SDGSection(
        title: "Challenges",
        summary: "Overconsumption and unsustainable production place significant pressure on the planet.",
        keyPoints: [
            "Growing waste generation",
            "Resource depletion",
            "Environmental degradation"
        ]
    ),
    SDGSection(
        title: "How You Can Help",
        summary: "Simple daily habits can reduce environmental impact and promote sustainability.",
        keyPoints: [
            "Reuse and recycle responsibly",
            "Avoid unnecessary consumption",
            "Choose sustainable products"
        ]
    ),
    SDGSection(
        title: "Impact",
        summary: "Sustainable consumption leads to healthier ecosystems and a more balanced future.",
        keyPoints: [
            "Reduced pollution",
            "Resource conservation",
            "Environmental sustainability"
        ]
    )
],
"13": [
    SDGSection(
        title: "Why This Goal Matters",
        summary: "Climate change is one of the greatest challenges of our time. Protecting the planet today ensures a safer, healthier world for future generations.",
        keyPoints: [
            "Climate impacts affect ecosystems and communities",
            "Protecting the environment safeguards livelihoods",
            "Collective action can slow global warming"
        ]
    ),
    SDGSection(
        title: "Challenges",
        summary: "Rising temperatures, extreme weather, and environmental degradation continue to threaten global stability and well-being.",
        keyPoints: [
            "Increasing greenhouse gas emissions",
            "Frequent climate-related disasters",
            "Need for stronger global cooperation"
        ]
    ),
    SDGSection(
        title: "How You Can Help",
        summary: "Every action counts — from daily habits to raising awareness — you can be part of the solution.",
        keyPoints: [
            "Reduce energy consumption",
            "Support climate initiatives",
            "Promote sustainable lifestyles"
        ]
    ),
    SDGSection(
        title: "Impact",
        summary: "Taking climate action protects ecosystems, strengthens resilience, and preserves our shared home.",
        keyPoints: [
            "Healthier planet",
            "Safer communities",
            "Long-term sustainability"
        ]
    )
],

"14": [
    SDGSection(
        title: "Why This Goal Matters",
        summary: "Oceans sustain life on Earth by regulating climate, supporting biodiversity, and providing food and livelihoods for billions.",
        keyPoints: [
            "Marine ecosystems support global balance",
            "Oceans absorb carbon and regulate climate",
            "Healthy seas ensure food security"
        ]
    ),
    SDGSection(
        title: "Challenges",
        summary: "Pollution, overfishing, and climate change are placing immense pressure on marine environments.",
        keyPoints: [
            "Plastic pollution harming marine life",
            "Declining fish populations",
            "Ocean warming and acidification"
        ]
    ),
    SDGSection(
        title: "How You Can Help",
        summary: "Protecting oceans starts with mindful choices that reduce harm and support conservation.",
        keyPoints: [
            "Reduce plastic usage",
            "Support marine conservation efforts",
            "Spread awareness about ocean protection"
        ]
    ),
    SDGSection(
        title: "Impact",
        summary: "Healthy oceans sustain biodiversity, support economies, and maintain climate balance.",
        keyPoints: [
            "Thriving marine ecosystems",
            "Sustainable fisheries",
            "Climate stability"
        ]
    )
],

"15": [
    SDGSection(
        title: "Why This Goal Matters",
        summary: "Life on land provides the foundation for biodiversity, food systems, and ecological balance essential for survival.",
        keyPoints: [
            "Forests and ecosystems support life",
            "Biodiversity strengthens resilience",
            "Healthy land supports sustainable futures"
        ]
    ),
    SDGSection(
        title: "Challenges",
        summary: "Deforestation, habitat loss, and land degradation continue to threaten ecosystems worldwide.",
        keyPoints: [
            "Loss of wildlife habitats",
            "Soil degradation",
            "Declining biodiversity"
        ]
    ),
    SDGSection(
        title: "How You Can Help",
        summary: "Protecting nature begins with conscious actions that respect and restore the environment.",
        keyPoints: [
            "Plant and protect trees",
            "Support conservation programs",
            "Reduce environmental footprint"
        ]
    ),
    SDGSection(
        title: "Impact",
        summary: "Healthy ecosystems promote climate stability, biodiversity, and long-term sustainability.",
        keyPoints: [
            "Protected wildlife",
            "Balanced ecosystems",
            "Resilient environments"
        ]
    )
],

"16": [
    SDGSection(
        title: "Why This Goal Matters",
        summary: "Peace, justice, and strong institutions create the foundation for safe, fair, and inclusive societies where people can thrive.",
        keyPoints: [
            "Justice protects human rights",
            "Peace enables development",
            "Trust strengthens communities"
        ]
    ),
    SDGSection(
        title: "Challenges",
        summary: "Conflict, inequality, and lack of transparency continue to undermine progress in many parts of the world.",
        keyPoints: [
            "Violence and instability",
            "Corruption and weak governance",
            "Limited access to justice"
        ]
    ),
    SDGSection(
        title: "How You Can Help",
        summary: "Promoting fairness, respect, and accountability helps build stronger and more peaceful communities.",
        keyPoints: [
            "Encourage transparency",
            "Stand for fairness and equality",
            "Support inclusive dialogue"
        ]
    ),
    SDGSection(
        title: "Impact",
        summary: "Peaceful and just societies foster trust, stability, and sustainable progress.",
        keyPoints: [
            "Safer communities",
            "Stronger governance",
            "Inclusive growth"
        ]
    )
],

"17": [
    SDGSection(
        title: "Why This Goal Matters",
        summary: "Global challenges require collective action. Partnerships unite people, ideas, and resources to drive meaningful change.",
        keyPoints: [
            "Collaboration accelerates progress",
            "Shared knowledge strengthens solutions",
            "Global cooperation builds resilience"
        ]
    ),
    SDGSection(
        title: "Challenges",
        summary: "Achieving alignment across nations, organizations, and communities requires trust, coordination, and sustained commitment.",
        keyPoints: [
            "Funding and resource gaps",
            "Policy differences",
            "Coordination challenges"
        ]
    ),
    SDGSection(
        title: "How You Can Help",
        summary: "Working together — locally and globally — amplifies impact and drives progress toward shared goals.",
        keyPoints: [
            "Collaborate and share ideas",
            "Support community initiatives",
            "Promote collective action"
        ]
    ),
    SDGSection(
        title: "Impact",
        summary: "Strong partnerships create lasting change, unlock innovation, and bring us closer to a sustainable future for all.",
        keyPoints: [
            "Accelerated progress",
            "Stronger global connections",
            "Shared success"
        ]
    )
]
]


extension FivePInfo {
    
    static let all: [FivePInfo] = [
        
        FivePInfo(
            type: .people,
            title: "People",
            shortTagline: "Dignity, equality and basic human needs.",
            detailedDescription: """
                People represents the human foundation of sustainable development. Goals 1–5 focus on eliminating poverty and hunger, ensuring access to health and education, and empowering women and girls. 

                This pillar indicates that development must begin with protecting human dignity. Without meeting basic needs and ensuring equality, no society can achieve lasting progress. The principle of “leave no one behind” is rooted in this category.
                """,
            sdgNumbers: [1,2,3,4,5],
            colorHex: "#6C73B8",
            symbolName: "person.3.fill"
        ),
        
        FivePInfo(
            type: .planet,
            title: "Planet",
            shortTagline: "Protecting natural resources and climate.",
            detailedDescription: """
            Planet focuses on environmental protection and responsible resource management. Goals 6, 12, 13, 14 and 15 address water security, sustainable production, climate action, and protection of life below water and on land.

            This pillar indicates that human survival depends entirely on ecological balance. Sustainable development is impossible if ecosystems collapse. Protecting the planet ensures that present and future generations can thrive.
            """,
            sdgNumbers: [6,12,13,14,15],
            colorHex: "#2DAA62",
            symbolName: "leaf.fill"
        ),
        
        FivePInfo(
            type: .prosperity,
            title: "Prosperity",
            shortTagline: "Inclusive growth and innovation.",
            detailedDescription: """
                Prosperity represents sustainable economic growth and innovation. Goals 7–11 focus on clean energy, decent work, infrastructure, reduced inequalities, and sustainable cities.

                This pillar indicates that economic progress must not destroy social equity or the environment. True prosperity balances energy use, industrial growth, and innovation with fairness and sustainability.
                """,
            sdgNumbers: [7,8,9,10,11],
            colorHex: "#F39200",
            symbolName: "chart.line.uptrend.xyaxis"
        ),
        
        FivePInfo(
            type: .peace,
            title: "Peace",
            shortTagline: "Justice, security and strong institutions.",
            detailedDescription: """
                Peace emphasizes the importance of justice, accountability and inclusive institutions. Goal 16 promotes rule of law, reduction of violence, and strong governance systems.

                This pillar indicates that development cannot occur in unstable or unjust societies. Without peace, progress collapses. Strong institutions protect rights, ensure fairness, and build trust within communities.
                """,
            sdgNumbers: [16],
            colorHex: "#3C8DBC",
            symbolName: "scale.3d"
        ),
        
        FivePInfo(
            type: .partnership,
            title: "Partnership",
            shortTagline: "Global cooperation for shared progress.",
            detailedDescription: """
                Partnership highlights collaboration between governments, private sectors, civil society, and individuals. Goal 17 strengthens global solidarity, financing, technology sharing, and international cooperation.

                This pillar indicates that no country or community can achieve sustainable development alone. The SDGs require collective responsibility and shared action across borders and sectors.
                """,
            sdgNumbers: [17],
            colorHex: "#7F3F98",
            symbolName: "circle.grid.2x2.fill"
        )
    ]
}
