<template>
  <q-page ref="mapref">
    <ol-map
      ref="map"
      :loadTilesWhileAnimating="true"
      :loadTilesWhileInteracting="true"
      style="height: 100vh; width: 100vw"
    >
      <div class="z-top fixed-top-right q-ma-xs">
        <q-btn
          :to="{ path: '/' }"
          color="primary"
          icon="fa fa-home"
          class="shadow-1"
          round
          flat
        />
      </div>
      <div class="z-top fixed-bottom-left" style="max-width: 100vw">
        <q-card class="q-gutter-sm row bg-transparent" flat>
          <q-card-section class="col-3 self-end">
            <q-btn
              icon="fa fa-gear"
              color="primary"
              class="q-pa-sm shadow-1"
              @click="openOptions = !openOptions"
              round
            />
          </q-card-section>
          <q-card-section class="q-ma-sm bg-secondary col" v-if="openOptions">
            <q-badge color="primary" label="Base Map" />
            <q-select
              v-model="selectedXYZ"
              :options="maps"
              bg-color="transparent"
              menu-anchor="center end"
            />
            <br />
            <q-badge color="primary" label="Number of Hours" />
            <q-slider v-model="time" :min="1" :max="48" :step="1" label />
            <br />
            <q-btn
              outline
              class="full-width"
              label="Refresh"
              dropdown-icon="fa fa-caret-down"
              :icon-right="refreshIcon"
              @click="loadIncidents()"
            />
          </q-card-section>
        </q-card>
      </div>

      <q-drawer> </q-drawer>

      <ol-view
        ref="view"
        :center="center"
        :zoom="zoom"
        :projection="projection"
      />

      <ol-zoom-control />

      <ol-tile-layer>
        <ol-source-xyz :url="selectedXYZ.value" />
      </ol-tile-layer>

      <ol-vector-layer>
        <ol-source-vector>
          <ol-feature v-for="item in incidents" :key="item.id">
            <ol-geom-point
              :coordinates="[item.location.lon, item.location.lat]"
            >
            </ol-geom-point>
            <ol-style>
              <ol-style-icon
                src="https://pbs.twimg.com/profile_images/647397513415290880/wdKzuYSQ_400x400.png"
                v-if="item.agency == 'kent911Fire' || item.agency == 'grfd'"
                :scale="0.1"
              ></ol-style-icon>
              <ol-style-icon
                src="https://upload.wikimedia.org/wikipedia/en/4/4b/Grand_Rapids_Police_Department_seal.png"
                v-if="item.agency == 'grpd'"
                :scale="0.1"
              />
              <ol-style-icon
                src="https://pbs.twimg.com/profile_images/1518633674773827585/5sEjLwnE_400x400.jpg"
                v-if="item.agency == 'kent911Police'"
                :scale="0.1"
              />
              <ol-style-text
                :text="
                  item.description + '\n' + moment(item.created_at).fromNow()
                "
                :offsetY="-30"
                v-if="item.agency == 'kent911Fire' || item.agency == 'grfd'"
              />
              <ol-style-text
                :text="
                  item.description + '\n' + moment(item.created_at).fromNow()
                "
                :offsetY="30"
                v-else
              />
            </ol-style>
          </ol-feature>
        </ol-source-vector>
      </ol-vector-layer>
    </ol-map>
  </q-page>
</template>

<script lang="ts">
import { api } from 'boot/axios';
import { ref } from 'vue';
import moment from 'moment-timezone';
moment().tz('America/Detroit').format();

export default {
  setup() {
    const center = ref([-85.599446, 43.064233]);
    const zoom = 11.5;

    return {
      center,
      zoom,
      moment,
    };
  },
  mounted() {
    this.loadIncidents();
    setInterval(this.loadIncidents, 1000 * 60);
  },
  data() {
    return {
      incidents: [
        {
          id: '',
          agency: '',
          description: '',
          created_at: '',
          location: {
            lat: 0,
            lon: 0,
          },
        },
      ],
      time: 6,
      openOptions: false,
      rotation: 0,
      projection: 'EPSG:4326',
      loaded: true,
      selectedXYZ: {
        label: 'Open Street Map Standard',
        value:
          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      },
      maps: [
        {
          label: 'Google Maps',
          value: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
        },
        {
          label: 'Google Satellite',
          value: 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
        },
        {
          label: 'Google Terrain',
          value: 'https://mt1.google.com/vt/lyrs=t&x={x}&y={y}&z={z}',
        },
        {
          label: 'Google Terrain Hybrid',
          value: 'https://mt1.google.com/vt/lyrs=p&x={x}&y={y}&z={z}',
        },
        {
          label: 'Google Satellite Hybrid',
          value: 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
        },
        {
          label: 'Esri Gray (dark)',
          value:
            'https://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}',
        },
        {
          label: 'Esri Gray (light)',
          value:
            'https://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}',
        },
        {
          label: 'Esri Satellite',
          value:
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        },
        {
          label: 'Esri Standard',
          value:
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
        },
        {
          label: 'Esri Transportation',
          value:
            'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Transportation/MapServer/tile/{z}/{y}/{x}',
        },
        {
          label: 'Esri World Imagery',
          value:
            'https://services.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        },
        {
          label: 'Esri Topo World',
          value:
            'https://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
        },
        {
          label: 'Open Street Map Standard',
          value: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        },
      ],
    };
  },
  computed: {
    refreshIcon() {
      return this.loaded ? 'fas fa-sync' : 'fas fa-circle-notch fa-spin';
    },
  },
  methods: {
    loadIncidents() {
      this.loaded = false;
      api.get('v1/kent911/incidents?ago=' + this.time * 60).then((response) => {
        this.incidents = response.data.incidents;
        this.loaded = true;
      });
    },
  },
};
</script>
