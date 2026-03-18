# 🌸 Luxury Fragrance: Consumer Preference Analysis

**Domain:** E-commerce Market Research & Competitor Analysis

<img width="1118" height="644" alt="image" src="https://github.com/user-attachments/assets/7d382a22-ef8f-4642-8508-6b0e230c6265" />

## 1. Project Overview
The global fragrance market is saturated with thousands of scents. This project doesn't just look at what sells; it dissects **why** it sells. By reverse-engineering community reviews from a dataset of over 70,000+ validated perfumes, this project uncovers the hidden correlations between scent profiles (accords) and true consumer consensus.

## 2. Tech Stack & Architecture
This project demonstrates an end-to-end data pipeline:
* **Python (Data Engineering - Pandas, NumPy):** Cleaned unstructured scraped data, utilized Regex to extract accurate brand names, un-nested stringified arrays for olfactory notes, and handled missing values through strategic imputation. Reduced data size from ~70k noisy records to ~63k validated entries.
* **SQL Server (Statistical Modeling):** Solved the "Rating Bias Dilemma" (where niche products with 5 votes outrank popular items) by engineering a **Weighted Rating Model** inspired by IMDb's Bayesian ranking. Encapsulated logic into a live SQL View `dbo.perfume_weighted`.
* **Power BI (Data Visualization):** Built an executive-ready, interactive decision-support dashboard highlighting macro market structures and micro-level product performance.

## 3. Key Business Discoveries ("Aha!" Moments)

### 💡 Insight 1: The "Fresh" Illusion vs. The "Warm" Reality (Quantity vs. Quality)
At first glance, the market appears dominated by Fresh and Citrus fragrances purely by production volume. However, deeper SQL analysis revealed that fragrances built around warmer, complex accords—such as **Vanilla, Amber, Tobacco, Oud, and Warm Spices**—consistently achieved the highest weighted ratings. 
*👉 **Takeaway:** Fresh scents dominate volume, but richer compositions dominate consumer appreciation.*

### 🏆 Insight 2: The True Consumer Consensus Leaderboard
By applying the Weighted Rating model to filter out artificially inflated scores, the revised rankings surfaced a different reality. The true top performers (e.g., *Le Male Le Parfum, Stronger With You Intensely, Spicebomb Extreme*) all share a common denominator: **A refined balance of sweet, spicy, and warm woody bases**.

## 4. Business Impact
For a fragrance house or e-commerce platform, insights like these help move beyond launching yet another generic citrus cologne, toward formulating fragrances with stronger potential for high ratings and lasting consumer appeal, specifically focusing on rich amber-vanilla compositions.
