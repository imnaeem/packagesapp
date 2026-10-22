import { Router } from 'express';
import { authenticate } from '../../middleware/auth.middleware';
import * as controller from './favourite.controller';

const router = Router();

router.use(authenticate);

router.get('/', controller.getFavourites);
router.post('/sync', controller.syncFavourites);
router.post('/:packageId', controller.addFavourite);
router.delete('/:packageId', controller.removeFavourite);

export default router;
