/*
 * Copyright (C) 2019 ETH Zurich and University of Bologna
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* Driver to control and configure the PULP IRQ (apb_interrupt_control)*/
/* Author: Robert Balas (balasr@iis.ee.ethz.ch)
 */
#include <stdint.h>

#include "pulp_mem_map.h"
#include "pulp_io.h"
#include "irq.h"

void irq_mask(uint32_t mask)
{
	writew(mask, (uint32_t *)(PULP_FC_IRQ_ADDR + IRQ_REG_MASK_OFFSET));
}

void irq_enable(uint32_t mask)
{
	writew(mask, (uint32_t *)(PULP_FC_IRQ_ADDR + IRQ_REG_MASK_SET_OFFSET));
}

void irq_disable(uint32_t mask)
{
	writew(mask,
	       (uint32_t *)(PULP_FC_IRQ_ADDR + IRQ_REG_MASK_CLEAR_OFFSET));
}