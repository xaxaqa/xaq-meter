const { createApp } = Vue

createApp({
    data() {
        return {
            fare: 0,
            display: false,
            isActive: false,
            isStarting: false,
            isForcedStop: false
        }
    },
    computed: {
        formatFare() {
            return this.fare.toFixed(2)
        },
        status() {
            return this.isActive ? 'RUNNING' : 'STOPPED'
        }
    },
    methods: {
        startMeter() {
            this.isStarting = true
            setTimeout(() => this.isStarting = false, 1000)
        },
        stopMeter(forced) {
            this.isForcedStop = forced
            setTimeout(() => this.isForcedStop = false, 1000)
        }
    },
    mounted() {
        window.addEventListener('message', (event) => {
            const { type, display, fare, starting, forced } = event.data
            
            if (type === 'updateMeter') {
                this.fare = fare
                this.isActive = true
            } else if (type === 'showMeter') {
                if (display) {
                    this.display = true
                    this.fare = fare || 0
                    this.isActive = true
                    starting && this.startMeter()
                } else {
                    this.isActive = false
                    this.stopMeter(forced)
                    setTimeout(() => this.display = false, 300)
                }
            }
        })
    }
}).mount('#app') 