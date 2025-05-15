import { createRouter, createWebHistory } from "vue-router";
// Import the new view components
import CardView from "../components/CardView.vue";
import MemberView from "../components/MemberView.vue";
import SaleView from "../components/SaleView.vue";
// App.vue will serve as the main layout/data fetcher
import App from "../App.vue";

const routes = [
  {
    path: "/",
    name: "Card",
    component: CardView, // Use CardView component
    props: true,
  },
  {
    path: "/member",
    name: "Member",
    component: MemberView, // Use MemberView component
    props: true,
  },
  {
    path: "/sale",
    name: "Sale",
    component: SaleView, // Use SaleView component
    props: true,
  },
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL), // Using base_url from vite config
  routes,
});

export default router;
