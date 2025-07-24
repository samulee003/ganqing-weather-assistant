# 甘青行程智能助手 - 人流密度API集成指南

## 📊 實時人流密度數據獲取方案

### 概述
本文檔說明如何在甘青行程智能助手中集成實時人流密度數據，提供多種API方案和實現策略。

---

## 🎯 已實現功能

### ✅ 當前實現
- **多數據源支持**：百度慧眼、Google Places API、模擬數據
- **實時數據更新**：基於時間的動態計算
- **智能時段分析**：根據不同時段調整人流密度
- **視覺化展示**：實時圖表和卡片展示
- **預警系統**：高密度時段自動提醒

---

## 🔧 技術實現方案

### 1. 百度慧眼 API（推薦）

#### 優勢
- ✅ 數據覆蓋全面，準確度高
- ✅ 實時熱力圖數據
- ✅ 支持景區人流分析
- ✅ 官方商業API，數據可靠

#### 實現方式
```javascript
// 百度慧眼人流密度API調用
async function fetchBaiduCrowdData() {
  const response = await fetch(`https://huiyan.baidu.com/api/crowd/density`, {
    method: 'POST',
    headers: {
      'Authorization': 'Bearer YOUR_API_KEY',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      location: city.coord,
      radius: 5000,
      type: 'tourism'
    })
  });
  return response.json();
}
```

#### 成本考量
- 需要商業授權
- 按調用次數計費
- 建議：企業級項目使用

---

### 2. Google Places API Popular Times

#### 優勢
- ✅ 全球數據覆盖
- ✅ 與Google Maps整合
- ✅ 豐富的場所信息

#### 限制
- ❌ Popular Times數據不在官方API中直接提供
- ❌ 需要通過第三方庫或爬蟲獲取
- ❌ 數據更新頻率有限

#### 實現方式
```javascript
// 使用第三方庫獲取Google Popular Times
const populartimes = require('populartimes');

async function fetchGooglePopularTimes(placeId) {
  try {
    const data = await populartimes.getPopularTimes(placeId);
    return data.populartimes;
  } catch (error) {
    console.error('Google API Error:', error);
    return null;
  }
}
```

---

### 3. 高德地圖人流密度

#### 實現方式
```javascript
// 高德地圖周邊POI + 人流估算
async function fetchAmapCrowdData(location) {
  const poiUrl = `https://restapi.amap.com/v3/place/around?key=${AMAP_KEY}&location=${location}&types=景點&radius=3000`;
  const poiResponse = await fetch(poiUrl);
  const poiData = await poiResponse.json();
  
  // 根據POI數量和熱度估算人流
  return estimateCrowdFromPOI(poiData.pois);
}
```

---

## 📈 智能算法實現

### 時段人流係數計算
```javascript
function getTimeMultiplier(hour) {
  const hourFactors = {
    6: 0.3,  7: 0.5,  8: 0.7,  9: 1.3,  10: 1.4,
    11: 1.3, 12: 1.1, 13: 1.0, 14: 1.4, 15: 1.4,
    16: 1.4, 17: 1.3, 18: 1.1, 19: 1.2, 20: 1.1,
    21: 0.9, 22: 0.6, 23: 0.3, 0: 0.1,  1: 0.1,
    2: 0.1,  3: 0.1,  4: 0.1,  5: 0.2
  };
  return hourFactors[hour] || 1.0;
}
```

### 城市基礎負載配置
```javascript
const cityBaseLoads = {
  '蘭州': 65,    // 省會城市，中等人流
  '門源': 45,    // 季節性景點
  '張掖': 85,    // 熱門景區
  '嘉峪關': 70,  // 歷史景點
  '敦煌': 95,    // 超熱門景區
  '大柴旦': 25,  // 偏遠地區
  '茶卡': 90,    // 網紅打卡地
  '西寧': 60     // 交通樞紐
};
```

---

## 🚀 部署建議

### 1. 開發階段
- 使用模擬數據進行功能開發
- 實現數據源切換機制
- 測試不同時段的數據表現

### 2. 生產環境
- **小型項目**：使用智能估算算法
- **中型項目**：集成免費API + 智能算法
- **企業項目**：購買百度慧眼商業授權

### 3. 混合方案（推薦）
```javascript
async function getOptimalDensityData(city) {
  try {
    // 優先嘗試百度慧眼
    return await fetchBaiduCrowdData(city);
  } catch (error) {
    try {
      // 備用Google數據
      return await fetchGooglePopularTimes(city);
    } catch (error2) {
      // 最終使用智能算法
      return generateSmartEstimate(city);
    }
  }
}
```

---

## 📋 數據格式標準

### 統一數據結構
```javascript
{
  location: "張掖",
  density: 85,              // 0-100的擁擠度
  peak: "16:00-18:00",     // 高峰時段
  tip: "建議預約門票",      // 遊覽建議
  source: "baidu",         // 數據來源
  isRealTime: true,        // 是否實時數據
  lastUpdate: "14:30:25",  // 最後更新時間
  coordinates: {
    lat: 38.932696,
    lng: 100.455497
  }
}
```

---

## ⚡ 性能優化

### 1. 數據緩存策略
```javascript
const densityCache = new Map();
const CACHE_DURATION = 10 * 60 * 1000; // 10分鐘

function getCachedDensity(location) {
  const cached = densityCache.get(location);
  if (cached && Date.now() - cached.timestamp < CACHE_DURATION) {
    return cached.data;
  }
  return null;
}
```

### 2. 批量API調用
```javascript
async function batchFetchDensity(cities) {
  const promises = cities.map(city => 
    fetchDensityWithRetry(city).catch(err => ({
      ...city,
      density: estimateDensity(city),
      error: err.message
    }))
  );
  return Promise.all(promises);
}
```

---

## 🔍 監控和分析

### 數據質量監控
- API調用成功率
- 數據更新頻率
- 異常值檢測
- 用戶反饋收集

### 使用統計
- 熱門查詢時段
- 用戶偏好分析
- 預警觸發頻率

---

## 📞 技術支持

### API提供商聯繫方式
- **百度慧眼**：https://huiyan.baidu.com/
- **Google Places**：https://developers.google.com/maps/
- **高德地圖**：https://lbs.amap.com/

### 開源替代方案
- OpenStreetMap Overpass API
- 社交媒體簽到數據分析
- 交通流量數據推算

---

## 📝 更新日誌

### v1.0.0 (2024-01-XX)
- ✅ 實現多數據源架構
- ✅ 集成百度慧眼接口
- ✅ 添加Google Places支持
- ✅ 完成智能算法估算
- ✅ 實現實時圖表展示

### 未來計劃
- 🔄 機器學習預測模型
- 🔄 社交媒體數據整合
- 🔄 用戶行為分析
- 🔄 個性化推薦算法

---

## ⚠️ 注意事項

1. **API使用條款**：確保遵守各API提供商的使用條款
2. **數據隱私**：妥善處理用戶位置等敏感數據
3. **成本控制**：監控API調用頻率，避免超出配額
4. **備用方案**：確保在API不可用時有替代方案
5. **數據準確性**：定期驗證數據準確性，調整算法參數

---

*本文檔隨項目發展持續更新，建議定期查看最新版本。* 