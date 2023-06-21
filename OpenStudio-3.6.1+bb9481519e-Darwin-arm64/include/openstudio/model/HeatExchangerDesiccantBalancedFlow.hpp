/***********************************************************************************************************************
*  OpenStudio(R), Copyright (c) 2008-2020, Alliance for Sustainable Energy, LLC, and other contributors. All rights reserved.
*
*  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
*  following conditions are met:
*
*  (1) Redistributions of source code must retain the above copyright notice, this list of conditions and the following
*  disclaimer.
*
*  (2) Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
*  disclaimer in the documentation and/or other materials provided with the distribution.
*
*  (3) Neither the name of the copyright holder nor the names of any contributors may be used to endorse or promote products
*  derived from this software without specific prior written permission from the respective party.
*
*  (4) Other than as required in clauses (1) and (2), distributions in any form of modifications or other derivative works
*  may not use the "OpenStudio" trademark, "OS", "os", or any other confusingly similar designation without specific prior
*  written permission from Alliance for Sustainable Energy, LLC.
*
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER(S) AND ANY CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
*  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
*  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER(S), ANY CONTRIBUTORS, THE UNITED STATES GOVERNMENT, OR THE UNITED
*  STATES DEPARTMENT OF ENERGY, NOR ANY OF THEIR EMPLOYEES, BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
*  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
*  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
*  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
*  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
***********************************************************************************************************************/

#ifndef MODEL_HEATEXCHANGERDESICCANTBALANCEDFLOW_HPP
#define MODEL_HEATEXCHANGERDESICCANTBALANCEDFLOW_HPP

#include "ModelAPI.hpp"
#include "AirToAirComponent.hpp"

namespace openstudio {

namespace model {

  class Schedule;
  class AirflowNetworkEquivalentDuct;
  class HeatExchangerDesiccantBalancedFlowPerformanceDataType1;

  namespace detail {

    class HeatExchangerDesiccantBalancedFlow_Impl;

  }  // namespace detail

  /** HeatExchangerDesiccantBalancedFlow is a AirToAirComponent that wraps the OpenStudio IDD object 'OS:HeatExchanger:AirToAir:SensibleAndLatent'. */
  class MODEL_API HeatExchangerDesiccantBalancedFlow : public AirToAirComponent
  {

   public:
    explicit HeatExchangerDesiccantBalancedFlow(const Model& model);

    explicit HeatExchangerDesiccantBalancedFlow(const Model& model,
                                                const HeatExchangerDesiccantBalancedFlowPerformanceDataType1& heatExchangerPerformance);

    virtual ~HeatExchangerDesiccantBalancedFlow() = default;
    // Default the copy and move operators because the virtual dtor is explicit
    HeatExchangerDesiccantBalancedFlow(const HeatExchangerDesiccantBalancedFlow& other) = default;
    HeatExchangerDesiccantBalancedFlow(HeatExchangerDesiccantBalancedFlow&& other) = default;
    HeatExchangerDesiccantBalancedFlow& operator=(const HeatExchangerDesiccantBalancedFlow&) = default;
    HeatExchangerDesiccantBalancedFlow& operator=(HeatExchangerDesiccantBalancedFlow&&) = default;

    static IddObjectType iddObjectType();

    Schedule availabilitySchedule() const;

    bool setAvailabilitySchedule(Schedule& schedule);

    HeatExchangerDesiccantBalancedFlowPerformanceDataType1 heatExchangerPerformance() const;

    bool setHeatExchangerPerformance(const HeatExchangerDesiccantBalancedFlowPerformanceDataType1& heatExchangerPerformance);

    bool economizerLockout() const;

    bool setEconomizerLockout(bool economizerLockout);

    AirflowNetworkEquivalentDuct getAirflowNetworkEquivalentDuct(double length, double diameter);
    boost::optional<AirflowNetworkEquivalentDuct> airflowNetworkEquivalentDuct() const;

   protected:
    /// @cond
    using ImplType = detail::HeatExchangerDesiccantBalancedFlow_Impl;

    explicit HeatExchangerDesiccantBalancedFlow(std::shared_ptr<detail::HeatExchangerDesiccantBalancedFlow_Impl> impl);

    friend class detail::HeatExchangerDesiccantBalancedFlow_Impl;
    friend class Model;
    friend class IdfObject;
    friend class openstudio::detail::IdfObject_Impl;

    /// @endcond

   private:
    REGISTER_LOGGER("openstudio.model.HeatExchangerDesiccantBalancedFlow");
  };

  /** \relates HeatExchangerDesiccantBalancedFlow*/
  using OptionalHeatExchangerDesiccantBalancedFlow = boost::optional<HeatExchangerDesiccantBalancedFlow>;

  /** \relates HeatExchangerDesiccantBalancedFlow*/
  using HeatExchangerDesiccantBalancedFlowVector = std::vector<HeatExchangerDesiccantBalancedFlow>;

}  // namespace model
}  // namespace openstudio

#endif  // MODEL_HEATEXCHANGERDESICCANTBALANCEDFLOW_HPP
