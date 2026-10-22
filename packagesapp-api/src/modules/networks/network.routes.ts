import { Router } from 'express';
import * as controller from './network.controller';

const router = Router();

router.get('/', controller.getNetworks);
router.get('/:id', controller.getNetwork);
router.post('/', controller.createNetwork);
router.post('/seed', controller.seedNetworks);

export default router;
