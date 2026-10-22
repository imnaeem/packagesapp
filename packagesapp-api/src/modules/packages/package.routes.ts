import { Router } from 'express';
import { validate } from '../../middleware/validate.middleware';
import { createPackageSchema, updatePackageSchema, packageQuerySchema } from './package.schema';
import * as controller from './package.controller';

const router = Router();

router.get('/', controller.getPackages);
router.get('/:id', controller.getPackage);
router.post('/', validate(createPackageSchema), controller.createPackage);
router.patch('/:id', validate(updatePackageSchema), controller.updatePackage);
router.delete('/:id', controller.deletePackage);

export default router;
