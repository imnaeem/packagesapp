import { env } from './config/env';
import { initFirebase } from './config/firebase';
import { seedNetworks } from './modules/networks/network.service';
import app from './app';

async function bootstrap(): Promise<void> {
  try {
    initFirebase();
    await seedNetworks();

    app.listen(env.PORT, () => {
      console.log(`🚀 Server running on port ${env.PORT} [${env.NODE_ENV}]`);
      console.log(`   Health: http://localhost:${env.PORT}/health`);
      console.log(`   API:    http://localhost:${env.PORT}/api/v1`);
    });
  } catch (err) {
    console.error('❌ Failed to start server:', err);
    process.exit(1);
  }
}

bootstrap();
