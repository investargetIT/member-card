<script setup>
import { defineProps } from "vue";

// Props expected from App.vue
defineProps({
  cardData: Object,
  cardImageSrc: String,
  cardBackground: String, // Specific to this view
});
</script>

<template>
  <div class="membership-card">
    <div class="card-content">
      <span class="card-no">{{ cardData?.cardNo }}</span>
      <img
        :src="cardBackground"
        alt="Card Background"
        class="card-background"
      />
      <img :src="cardImageSrc" alt="QR Code" class="qr-code" />
    </div>
  </div>
</template>

<style scoped>
.membership-card {
  border: 1px solid #ccc;
  border-radius: 8px;
  padding: 0;
  width: 350px;
  margin: 0;
  text-align: center;
  box-sizing: border-box;
  /* Ensure it's displayed for html2canvas even if App.vue controls visibility of wrapper */
  display: block;
}

.card-content {
  position: relative;
  width: 100%;
  min-height: 620px; /* Or adjust as needed */
  height: auto;
}

.card-no {
  position: absolute;
  top: 13.8%;
  left: 75.11%;
  font-weight: bold;
  color: #fff;
  font-size: 12px;
}

.card-background {
  width: 100%;
  height: auto;
  display: block;
}

.qr-code {
  width: 90px;
  position: absolute;
  top: 339px;
  left: 130px;
  height: auto;
  display: block;
  margin: 0 auto;
  border-radius: 50%;
}
</style>
